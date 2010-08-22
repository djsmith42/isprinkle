#include <ftdi.h>
#include <stdio.h>
#include <string.h>

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

#define ALL_OFF_MAGIC_NUMBER 42

struct cmd_line_args
{
    enum { query, run_zone, all_off } action;
    int zone_number; /* applies to the 'run_zone' action */
    int error;       /* 1: error, 0: all ok              */
};

static int usage(char **argv)
{
    printf("Usage: %s <options>\n", argv[0]);
    printf("\n");
    printf("  options:\n");
    printf("    --run-zone <number> Run a single zone (<number> can be 1 through 8).\n");
    printf("    --all-off           Turns off all zones.\n");
    printf("    --query             Prints current status to the console.\n");
    return EXIT_FAILURE;
}

static int initialize(struct ftdi_context *ftdic)
{
    int ret;

    if (ftdi_init(ftdic) < 0)
    {
        fprintf(stderr, "FTDI initialization failed\n");
        return 0;
    }

    // FIXME: Use ftdi_usb_find_all() and ftdi_usb_open_dev() to
    //        fint and open all FTDI devices.
    if ((ret = ftdi_usb_open(ftdic, 0x0403, 0x6001)) < 0)
    {
        fprintf(stderr, "Unable to open FTDI device: %d (%s)\n", ret, ftdi_get_error_string(ftdic));
        return 0;
    }

    unsigned int chipid;
    if(ftdi_read_chipid(ftdic, &chipid) == 0)
    {
        printf("Chipd ID: %X\n", chipid);
    }
    else
    {
        fprintf(stderr, "Could not read chipd ID.\n");
    }

    if ((ret = ftdi_set_baudrate(ftdic, 9600)) != 0)
    {
        fprintf(stderr, "Could not set baud rate, error: %d\n", ret);
        return 0;
    }

    if ((ret = ftdi_set_bitmode(ftdic, 0xff, BITMODE_BITBANG)) != 0)
    {
        fprintf(stderr, "Could not enable bitbang mode, error: %d\n", ret);
        return 0;
    }

    return 1;
}

static int do_all_off(struct ftdi_context *ftdic)
{
    unsigned char relay_control_bitmask = 0;
    int ret = ftdi_write_data_async(ftdic, &relay_control_bitmask, 1);
    if(ret != 1)
    {
        fprintf(stderr, "Could not send data to the relay board: 0x%02x\n", relay_control_bitmask);
        return EXIT_FAILURE;
    }
    else
    {
        return EXIT_SUCCESS;
    }
}

static int do_run_zone(struct ftdi_context *ftdic, int zone_number)
{
    unsigned char relay_control_bitmask = (1 << (zone_number-1));
    int ret = ftdi_write_data_async(ftdic, &relay_control_bitmask, 1);
    if(ret != 1)
    {
        fprintf(stderr, "Could not send data to the relay board: 0x%02x\n", relay_control_bitmask);
        return EXIT_FAILURE;
    }
    else
    {
        return EXIT_SUCCESS;
    }
}

static int do_query(struct ftdi_context *ftdic)
{
    unsigned char buf;
    int ret;
    if ((ret = ftdi_read_data(ftdic, &buf, 1)) == 1)
    {
        int i;
        for(i=0; i<8; i++)
        {
            int on = (buf & (1 << i));
            printf("Zone %d: %s\n", i+1, on ? "On" : "Off");
        }

        return EXIT_SUCCESS;
    }
    else
    {
        fprintf(stderr, "Could not read status from relay board: %d\n", ret);
        return EXIT_FAILURE;
    }
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
            if(args.zone_number < 1 || args.zone_number > 8)
            {
                fprintf(stderr, "Bad zone number. It should between 1 and 8\n");
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
    int ret;
    struct ftdi_context ftdic;

    struct cmd_line_args args = parse_cmd_line_args(argc, argv);

    if (args.error)
    {
        return usage(argv);
    }

    if(initialize(&ftdic))
    {
        switch(args.action)
        {
            case run_zone:
                ret = do_run_zone(&ftdic, args.zone_number);
                break;
            case all_off:
                ret = do_all_off(&ftdic);
                break;
            case query:
                ret = do_query(&ftdic);
                break;
        }

        if ((ret = ftdi_usb_close(&ftdic)) < 0)
        {
            fprintf(stderr, "Unable to close ftdi device: %d (%s)\n", ret, ftdi_get_error_string(&ftdic));
            ret = EXIT_FAILURE;
        }
    }

    ftdi_deinit(&ftdic);

    return ret;
}
