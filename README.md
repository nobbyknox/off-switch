# README

> For when you're dumped into darkness and your NAS is still running on a UPS that is rapidly running out of electro-juice.

## Installation

One simple BASH script. Copy it somewhere on your system. Easy. :-)

## Usage

```bash
$ /path/to/off-switch.sh -h <host to monitor> -t 60 -s /path/to/your/scripts
```

```
Arguments:

-h      Host to ping. As long as the host responds within the timeout
        period no action will take place.
-t      Timeout in seconds. Action will be taken if the host was not
        reachable within this period.
-s      Directory containing scripts to execute once the timeout occurs
        and the host was not reachable.
```