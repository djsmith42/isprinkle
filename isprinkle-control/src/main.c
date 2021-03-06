#include <ftdi.h>
#include <stdio.h>
#include <string.h>

#define MAX_SERIAL_LEN 255
#define ZONES_PER_BOARD 8

struct cmd_line_args
{
    enum { query, run_zone, all_off } action;
    int zone_number; /* applies to the 'run_zone' action */
    int error;       /* 1: error, 0: all ok              */
};

struct isprinkle_device
{
    char serial[MAX_SERIAL_LEN];
    struct usb_device *device;
};

struct isprinkle_context
{
    struct ftdi_context ftdic;
    struct isprinkle_device devices[16];
    int    num_devices;
    int    is_device_open;
};

static int usage(char **argv)
{
    printf("Usage: %s <options>\n", argv[0]);
    printf("\n");
    printf("  options:\n");
    printf("    --run-zone <number> Run a single zone (<number> starts with 1).\n");
    printf("    --all-off           Turns off all zones.\n");
    printf("    --query             Prints current status to the console.\n");
    return 1;
}

/**
 * Activates device 'device_number' such that all subsequent calls
 * to FTDI functions (like ftdi_write_data_async()) will be performed
 * on that device.
 *
 * 'device_number' must be between 0 and context->num_devices-1.
 *
 * Returns 1 on success, 0 on failure.
 * Prints to stderr on failure.
 */
static int use_device(struct isprinkle_context *context, int device_number)
{
    int ret;

    if ((ret = ftdi_usb_open_dev(&context->ftdic, context->devices[device_number].device)) < 0)
    {
        fprintf(stderr, "Unable to open FTDI device: %d (%s)\n", ret, ftdi_get_error_string(&context->ftdic));
        return 0;
    }

    if ((ret = ftdi_set_baudrate(&context->ftdic, 9600)) != 0)
    {
        fprintf(stderr, "Could not set baud rate, error: %d\n", ret);
        return 0;
    }

    if ((ret = ftdi_set_bitmode(&context->ftdic, 0xff, BITMODE_BITBANG)) != 0)
    {
        fprintf(stderr, "Could not enable bitbang mode, error: %d\n", ret);
        return 0;
    }

    context->is_device_open = 1;

    return 1;
}

static void sort_devices_by_serial(struct isprinkle_context *context)
{
    // Sort boards by serial number so they are always in the
    // same order, regardless of how libftdi reports them:
    if(context->num_devices > 1)
    {
        int i, j;

        // Drop-dead stupid O(n^2) sort:
        for(i=0; i<context->num_devices; i++)
        {
            for(j=i+1; j<context->num_devices; j++)
            {
                if(strcmp(context->devices[j].serial, context->devices[i].serial) < 0)
                {
                    // Swap:
                    struct isprinkle_device tmp = context->devices[i];
                    context->devices[i] = context->devices[j];
                    context->devices[j] = tmp;
                }
            }
        }
    }
}

static int initialize(struct isprinkle_context *context)
{
    int ret;

    context->is_device_open = 0;

    if (ftdi_init(&context->ftdic) < 0)
    {
        fprintf(stderr, "FTDI initialization failed\n");
        return 0;
    }

    struct ftdi_device_list *device_list;
    ret = ftdi_usb_find_all(&context->ftdic, &device_list, 0x0403, 0x6001);
    if(ret > 0)
    {
        context->num_devices = ret;
        int device_count = 0;
        for(; device_list; device_list = device_list->next)
        {
            context->devices[device_count].device = device_list->dev;
            if((ret = ftdi_usb_get_strings(&context->ftdic,
                            context->devices[device_count].device,
                            NULL, 0, NULL, 0,
                            context->devices[device_count].serial, MAX_SERIAL_LEN)) != 0)
            {
                fprintf(stderr, "Unable to read FTDI device strings: %d (%s)\n", ret, ftdi_get_error_string(&context->ftdic));
                return 0;
            }

            device_count++;
        }

        sort_devices_by_serial(context);
        return 1;
    }
    else
    {
        fprintf(stderr, "Could not find any sprinkler boards connected via USB (code %d)\n", ret);
        return 0;
    }
}

static void shutdown(struct isprinkle_context *context)
{
    if(context->is_device_open)
    {
        #if 0 // for some reason, the call to ftdi_usb_close() hangs with multiple boards, so leave it out for now
        int ret;
        if ((ret = ftdi_usb_close(&context->ftdic)) < 0)
        {
            fprintf(stderr, "Unable to close ftdi device: %d (%s)\n", ret, ftdi_get_error_string(&context->ftdic));
        }
        #endif
    }

    ftdi_deinit(&context->ftdic);
}

/**
 * Turns off all zones of all connected devices.
 */
static int do_all_off(struct isprinkle_context *context)
{
    unsigned char relay_control_bitmask = 0;
    int i;
    for(i = 0; i<context->num_devices; i++)
    {
        if(use_device(context, i))
        {
            int ret = ftdi_write_data_async(&context->ftdic, &relay_control_bitmask, 1);
            if(ret != 1)
            {
                fprintf(stderr, "Could not send data to the relay board: 0x%02x\n", relay_control_bitmask);
                return 0;
            }

            ftdi_async_complete(&context->ftdic, 0);
        }
        else
        {
            return 0;
        }
    }

    printf("Turned all zones off\n");
    return 1;
}

/**
 * Turns on zone 'zone_number' by turning off all other zones and
 * locating the correct board for the specific zone and turning
 * on the relay that corresponds to 'zone_number'.
 */
static int do_run_zone(struct isprinkle_context *context, int zone_number)
{
    int i;

    int max_zone = context->num_devices * ZONES_PER_BOARD;

    if(zone_number > max_zone)
    {
        fprintf(stderr, "Bad zone number: %d. It should be %d or less because you only have %d board%s.\n", zone_number, max_zone, context->num_devices, context->num_devices == 1 ? "" : "s");
        return 0;
    }

    for(i = 0; i<context->num_devices; i++)
    {
        if(use_device(context, i))
        {
            int start_zone = i * ZONES_PER_BOARD + 1;
            int end_zone   = start_zone + ZONES_PER_BOARD;

            unsigned char relay_control_bitmask;
            if(start_zone <= zone_number && zone_number <= end_zone)
            {
                relay_control_bitmask = (1 << (zone_number - start_zone));
            }
            else
            {
                relay_control_bitmask = 0;
            }

            int ret = ftdi_write_data_async(&context->ftdic, &relay_control_bitmask, 1);
            if(ret != 1)
            {
                fprintf(stderr, "Could not send data to the relay board: 0x%02x\n", relay_control_bitmask);
                return 0;
            }

            ftdi_async_complete(&context->ftdic, 0);
        }
        else
        {
            return 0;
        }
    }

    printf("Turned on zone %d\n", zone_number);
    return 1;
}

/**
 * Prints the following to stdout:
 *  - List of boards and their serial numbers
 *  - All zones and whether they are on or off
 */
static int do_query(struct isprinkle_context *context)
{
    int zone_offset = 0;
    int i;

    for(i=0; i<context->num_devices; i++)
    {
        printf("Board %d Serial: %s\n", (i+1), context->devices[i].serial);
    }

    for(i=0; i<context->num_devices; i++)
    {
        if(use_device(context, i))
        {
            int ret;
            unsigned char buf;
            if ((ret = ftdi_read_data(&context->ftdic, &buf, 1)) == 1)
            {
                int i;
                for(i=0; i<ZONES_PER_BOARD; i++)
                {
                    int on = (buf & (1 << i));
                    printf("Zone %d: %s\n", zone_offset+i+1, on ? "On" : "Off");
                }
            }
            else
            {
                fprintf(stderr, "Could not read status from relay board: %d\n", ret);
                return 0;
            }
        }
        else
        {
            return 0;
        }

        zone_offset += ZONES_PER_BOARD;
    }

    return 1;
}

static struct cmd_line_args parse_cmd_line_args(int argc, char **argv)
{
    struct cmd_line_args args;

    args.zone_number = -1;
    args.error = 0;

    int i;
    for(i=1; i<argc; i++)
    {
        if(!strcmp(argv[i], "--run-zone"))
        {
            args.action = run_zone;
            i++;

            if(i >= argc)
            {
                fprintf(stderr, "The --run-zone argument requires a parameter\n");
                args.error = 1;
                goto done;
            }

            args.zone_number = atoi(argv[i]);
            if(args.zone_number < 1)
            {
                fprintf(stderr, "Bad zone number. It should be 1 or higher\n");
                args.error = 1;
                goto done;
            }
        }
        else if(!strcmp(argv[i], "--all-off"))
        {
            args.action = all_off;
        }
        else if(!strcmp(argv[i], "--query"))
        {
            args.action = query;
        }
        else
        {
            fprintf(stderr, "\n");
            fprintf(stderr, "Error: Incorrect command line parameter.\n");
            fprintf(stderr, "\n");
            args.error = 1;
            goto done;
        }
    }

done:
    return args;
}

int main(int argc, char **argv)
{
    int success;
    struct isprinkle_context context;

    struct cmd_line_args args = parse_cmd_line_args(argc, argv);

    if (args.error)
    {
        return usage(argv);
    }

    if(initialize(&context))
    {
        if(context.num_devices > 0)
        {
            switch(args.action)
            {
                case run_zone:
                    success = do_run_zone(&context, args.zone_number);
                    break;
                case all_off:
                    success = do_all_off(&context);
                    break;
                case query:
                    success = do_query(&context);
                    break;
            }
        }
        else
        {
            fprintf(stderr, "No USB relay boards found connected to this computer\n");
            success = 0;
        }
    }

    shutdown(&context);

    return (success ? 0 : 1);
}
