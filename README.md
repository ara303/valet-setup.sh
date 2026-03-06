# valet-setup.sh
A setup script for what Larvel Valet doesn't give you for PHP development.

## Needs:
- A recent Mac
- [Homebrew](https://brew.sh/)
- [Valet](https://laravel.com/docs/12.x/valet#installation), [PHP](https://formulae.brew.sh/formula/php), and [Mariadb](https://formulae.brew.sh/formula/php) installed

## Does:

- What Valet doesn't, specifically: 
  - Mariadb
  - Mailhog
  - Xdebug

## Gives:

A few handy `.env` variables and where to go to view Mailhog's emails as well as Xdebug's adapter endpoint.

## Status:

WIP. I made this because Valet Plus is abandonware, but I still like Valet the best for setting up PHP environments. I regularly need to quickly make a fresh development environments for testing or starting new PHP projects but  just running `valet park` (and `valet secure`) doesn't do enough by itself. I wanted to fix both of those problems.
