# valet-setup.sh
A setup script for what Larvel Valet doesn't give you for PHP development.

## Needs:
- A recent Mac
- [Homebrew](https://brew.sh/)
- [Valet](https://laravel.com/docs/12.x/valet#installation), [PHP](https://formulae.brew.sh/formula/php), and [Mariadb](https://formulae.brew.sh/formula/php) installed

## Use:

1. Copy `valet-setup.sh` in a Valet directory (`valet park`)
2. Run `bash valet-setup.sh`

## Does:

- What Valet doesn't, specifically: 
  - Mariadb
  - Mailhog
  - Xdebug

## Gives:

Generates a code block you can copy and paste into `.valet-env.php` ([or similar](https://www.julienbourdeau.com/valet-environment-variables-simplify-env-file/)), and shows you where to go for Mailhog's UI and Xdebug's adapter endpoint.

## Notes:

WIP.

I made this because Valet Plus is abandoned and archived. I still like Valet the most for setting up PHP development environments. Simply running `valet park` (and `valet secure`) doesn't do enough by itself. 

## For WordPress:

To use [`wp`](https://github.com/wp-cli/wp-cli) (or for LLM tool calls), manually require `.valet-env.php` in `wp-config.php` **in addition to** setting your database credentials:

```php
$valet_env = __DIR__ . '/.valet-env.php';
if ( file_exists( $valet_env ) ) {
    $valet_config = require $valet_env;
    $site_name = basename( __DIR__);
    if ( isset( $valet_config[$site_name] ) ) {
        foreach ( $valet_config[$site_name] as $key => $value ) {
            $_SERVER[$key] = $value;
        }
    }
}

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', $_SERVER['DB_DATABASE']);

/** MySQL database username */
define('DB_USER', $_SERVER['DB_USERNAME']);

/** MySQL database password */
define('DB_PASSWORD', $_SERVER['DB_PASSWORD']);

/** MySQL hostname */
define('DB_HOST', $_SERVER['DB_HOST']);
```
