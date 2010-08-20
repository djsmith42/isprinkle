#include <stdio.h>
#include <ftdi.h>

#define ALL_OFF_MAGIC_NUMBER 42

int main(int argc, char **argv)
{
    int zone_number = -1;
    int turn_all_relays_off = 0;
    int ret;
    int i;
    struct ftdi_context ftdic;

    for(i=1; i<argc; i++)
    {
        if(!strcmp(argv[i], "--run-zone"))
        {
            i++;

            if(i >= argc)
            {
                fprintf(stderr, "The --run-zone argument requires a parameter\n");
                return EXIT_FAILURE;
            }

            zone_number = atoi(argv[i]);
            if(zone_number >= 1 && zone_number <= 8)
            {
                // The bit-mask is zero-indexed:
                zone_number--;
            }
            else
            {
                fprintf(stderr, "Bad zone number. It should between 1 and 8\n");
                return EXIT_FAILURE;
            }
        }
        else if(!strcmp(argv[i], "--all-off"))
        {
            zone_number = ALL_OFF_MAGIC_NUMBER;
        }
        else
        {
            fprintf(stderr, "\n");
            fprintf(stderr, "Error: Incorrect command line parameter.\n");
            fprintf(stderr, "\n");
        }
    }

    if(zone_number == -1)
    {
        printf("Usage: %s <options>\n", argv[0]);
        printf("\n");
        printf("  options:\n");
        printf("    --run-zone <number> Run a single zone (<number> can be 1 through 8).\n");
        printf("    --all-off           Turns off all zones.\n");
        return EXIT_FAILURE;
    }

    if (ftdi_init(&ftdic) < 0)
    {
        fprintf(stderr, "FTDI initialization failed\n");
        return EXIT_FAILURE;
    }

    if ((ret = ftdi_usb_open(&ftdic, 0x0403, 0x6001)) < 0)
    {
        fprintf(stderr, "Unable to open FTDI device: %d (%s)\n", ret, ftdi_get_error_string(&ftdic));
        return EXIT_FAILURE;
    }

    if ((ret = ftdi_set_baudrate(&ftdic, 9600)) != 0)
    {
        fprintf(stderr, "Could not set baud rate, error: %d\n", ret);
        return EXIT_FAILURE;
    }

    if ((ret = ftdi_set_bitmode(&ftdic, 0xff, BITMODE_BITBANG)) != 0)
    {
        fprintf(stderr, "Could not enable bitbang mode, error: %d\n", ret);
        return EXIT_FAILURE;
    }

    unsigned char relay_control_bitmask = (1 << zone_number);
    if(ALL_OFF_MAGIC_NUMBER == zone_number)
    {
        relay_control_bitmask = 0;
    }

    ret = ftdi_write_data_async(&ftdic, &relay_control_bitmask, 1);
    if(ret != 1)
    {
        fprintf(stderr, "Could not send data to the relay board: 0x%02x\n", relay_control_bitmask);
        return EXIT_FAILURE;
    }

    if ((ret = ftdi_usb_close(&ftdic)) < 0)
    {
        fprintf(stderr, "Unable to close ftdi device: %d (%s)\n", ret, ftdi_get_error_string(&ftdic));
        return EXIT_FAILURE;
    }

    ftdi_deinit(&ftdic);

    return EXIT_SUCCESS;
}
