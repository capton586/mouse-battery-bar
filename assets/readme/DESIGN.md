# README artwork

## Concept

A receiver report magnified beside the menu it drives. The last byte, `35` in hexadecimal, becomes the large 53% reading. The original menu preview anchors the other side of the spread. A battery gauge would lose the link to the hardware protocol, while a terminal-only cover would hide the app.

## Evidence and layout

The sample bytes and DPI are documented in [the VT9PRO example](../../docs/adapt.en.md#verified-example). The embedded image comes from [the recorded menu preview](../../docs/images/menu-preview.png). It shows an example reading. The same static artwork serves both languages, with localized alternative text and instructions in Markdown.

The editorial poster layout uses one split panel. The large percentage carries the result and the small monospaced line carries its source. The light palette uses paper `#F2F4F0`, ink `#142522` and a green marker `#116754`. The dark palette uses `#102420`, `#EFF8F2` and a luminous `#9BE9C3` marker. The separate menu panel preserves the original light-on-dark lettering. DIN Alternate Bold sets the percentage, with Courier New Bold for the device and packet. The published SVGs use glyph outlines. The editable source SVGs sit alongside them.

## Review log

At 830 pixels wide, the initial packet was small and the dark screenshot needed a quieter surround. The revision enlarged the packet and its label, deepened the panel, and increased the left inset. Both themes were rendered at 830 and 360 pixels. The mobile layout keeps the large percentage prominent, with the model, reading and instructions also available in Markdown or alt text.
