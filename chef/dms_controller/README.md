# dms_controller-cookbook

Role cookbook for a DMS controller.

Runs the dms_controller_base configuration with required extensions.

Typical extensions:

   * customize the key attributes - prefix (and attributes containing the prefix), use_https and monitor_lbs
   * add deployment of baseline images and web content

## Supported Platforms

Ubuntu 14.04

## Attributes


## Usage

### dms_controller::default

Include `dms_controller` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[dms_controller::default]"
  ]
}
```

## License and Authors

Author:: Epimorphics Ltd (<dave@epimorphics.com>)
