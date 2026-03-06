# valet-setup.sh
A turn-key solution to setup what Laravel Valet doesn't. Faster, easier PHP development.

## Needs:
- A recent Mac
- [Homebrew](https://brew.sh/)
- [Valet](https://laravel.com/docs/12.x/valet#installation) installed, with [PHP](https://formulae.brew.sh/formula/php), [Mariadb](https://formulae.brew.sh/formula/php), [Mailpit](https://formulae.brew.sh/formula/mailpit), and [Xdebug](https://xdebug.org/docs/install#pie)

## Use:

1. Copy `valet-setup.sh` in a Valet directory (`valet park`)
2. Run `bash valet-setup.sh`

## Does:

- What Valet doesn't, specifically: 
  - Mariadb
  - Mailpit
  - Xdebug

## Gives:

Generates a code block you can copy and paste into `.valet-env.php` ([or similar](https://www.julienbourdeau.com/valet-environment-variables-simplify-env-file/)), and shows you where to go for Mailpit's UI and Xdebug's adapter endpoint.

## Notes:

Work in progress.

I made this because Valet Plus is abandoned and archived. I still like Valet the most for setting up PHP development environments. Simply running `valet park` (and `valet secure`) doesn't do enough by itself. 

## For WordPress:

To use [`wp`](https://github.com/wp-cli/wp-cli) (or for LLM tool calls), manually require `.valet-env.php`'s values in `wp-config.php` when setting database constants:

```php
$valet_env = __DIR__ . '/.valet-env.php';
if ( file_exists( $valet_env ) ) {
    $valet_config = require $valet_env;
    $site_name = basename( __DIR__ );
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
