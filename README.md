## Lindenmayer System Library

Heavily based on this Javascript version:
[nylki/lindenmayer](https://github.com/nylki/lindenmayer)

### Usage

```
require 'lsystem'
lsystem = Lindenmayer::LSystem.new('F++F++F',
                                   {
                                     'F' => 'F-F++F-F'
                                   })
lsystem.iterate
=> 'F-F++F-F++F-F++F-F++F-F++F-F'
```
