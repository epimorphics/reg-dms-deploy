# dms_controller-cookbook

Role cookbook for a DMS controller.

Runs the dms_controller_base configuration with required extensions.

Typical extensions:

   * customize the key attributes - prefix (and attributes containing the prefix), use_https and monitor_lbs
   * add deployment of baseline images and web content

## Supported Platforms

Ubuntu 14.04

## Attributes

Attribute | Type | Usage
---|---|---
`baseline` | Hash of image configurations indexed by service name | Provides for installation of baseline images and web content associated with the named DMS data service.
`baseline.{servicename}.{env}_baseline_images` | List of strings | Gives a list of file names to be installed from the baseline folder in the dms_deploy S3 bucket. Where `{env}` various over `testing` and `production`.
`baseline.{servicename}.{env}_web_snapshot` | String | File name for tgz package of web content to be installed from the baseline folder in the dms_deploy S3 bucket. Where `{env}` various over `testing` and `production`.

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
