# ephp template

[![License: LGPL 2.1](https://img.shields.io/github/license/bragful/ephp_template.svg)](https://raw.githubusercontent.com/bragful/ephp_template/master/COPYING)
[![Gitter](https://img.shields.io/gitter/room/bragful/ephp.svg)](https://gitter.im/bragful/ephp)
[![Hex](https://img.shields.io/hexpm/v/ephp_template.svg)](https://hex.pm/packages/ephp_template)

This is a template system to let you to use PHP templates inside of [Phoenix Framework](https://phoenixframework.org/).

## Installation

The package can be installed by adding `ephp_template` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ephp_template, "~> 0.1.0"}
  ]
end
```

In addition to this you can add to the configuration file:

```elixir
config :phoenix, :template_engines,
    php: Ephp.Template
```

This way you can create PHP files inside of the template directories and use them in the same way as `.html.eex` files.

## Assigns

Usually from the controllers you can send data to the templates (and views). PHP cannot use the specific functions defined by Phoenix Framework but you can use all of the PHP functions available by default by the [ephp](https://github.com/bragful/ephp) project.

The assigns will be included as normal variables inside of PHP. For example, using this controller:

```elixir
defmodule PhptestWeb.PageController do
  use PhptestWeb, :controller

  def index(conn, _params) do
    render conn, "index.html",
           user: "admin",
           data: [%{"a" => 10, "b" => 20}, %{"a" => 11, "b" => 21}]
  end
end
```

You'll have access to `$user` and `$data` variables in the template. You can create the file `index.html.php` and then do whatever you need.

## Superglobals

Maybe it's not needed but you have populated `$_SERVER` (not completely), `$_REQUEST` (and `$_GET` and `$_POST` as well), `$_ENV` and `$_COOKIE`.

## Donation

If you want to support the project to advance faster with the development you can make a donation. Thanks!

[![paypal](https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CBYJ5V2ZWWZ8G)

Enjoy!
