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

### Context-Sensitive Productions

Supports left-only, right-only, and left-right context-Sensitive productions.

```
lsystem = Lindenmayer::LSystem.new('A[X]BC', 'A<B>C' => 'Z')
lsystem.iterate
=>  'A[X]ZC'
```