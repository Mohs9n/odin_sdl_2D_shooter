package main

import sdl "vendor:sdl2"

doInput :: proc() -> bool {
    quit:= false
    event: sdl.Event
    if sdl.PollEvent(&event){
        #partial switch event.type{
            case sdl.EventType.QUIT:
               return true
            case sdl.EventType.KEYDOWN:
                doKeyDown(&event.key)
            case sdl.EventType.KEYUP:
                doKeyUp(&event.key)
        }
    }
    return false
}

doKeyDown :: proc(event: ^sdl.KeyboardEvent) {
    if event.repeat == 0 && int(event.keysym.scancode) < MAX_KEYBOARD_KEYS {
        app.keyboard[event.keysym.scancode] = 1
    }
}

doKeyUp :: proc(event: ^sdl.KeyboardEvent) {
    if event.repeat == 0 && int(event.keysym.scancode) < MAX_KEYBOARD_KEYS {
        app.keyboard[event.keysym.scancode] = 0
    }
}