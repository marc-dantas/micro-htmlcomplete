# htmlcomplete
Micro editor plugin to improve user's quality-of-life using HTML in
the editor.

## Features
- Automatically close HTML tags
- Insertion of HTML boilerplate
- Automatic tag block indentation

## Installation
Install by cloning the source code into the plugin folder of your Micro.
```console
$ git clone https://github.com/marc-dantas/micro-htmlcomplete ~/.config/micro/plug/htmlcomplete
```

## Usage
This plugin autocompletes tag closings when you do `<[TAG]>`,
it automatically detects that you're beginning a tag and adds the
corresponding closing for it.

> NOTE: If the tag you are using is a
> self-closing tag (that uses just `/>` instead of `< />`),
> it also completes the closing accordingly.

To insert HTML boilerplate, just type `<!DOCTYPE html>`.

The automatic indentation works when you press enter inside a tag.
It adds indentation and also positions the cursor properly so you
can type flawlessly.
