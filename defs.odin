package main

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

PLAYER_SPEED :: 8
PLAYER_BULLET_SPEED :: 16
ALIEN_BULLET_SPEED :: 8

MAX_KEYBOARD_KEYS :: 350

SIDE_PLAYER :: 0
SIDE_ALIEN :: 1

FPS :: 60

App :: struct {
    renderer: ^sdl.Renderer,
    window:   ^sdl.Window,
    keyboard: [MAX_KEYBOARD_KEYS]int,
}
app : App

Entity :: struct {
    x, y, dx, dy: f32,
    w, h, health, reload, side: i32,
    texture: ^sdl.Texture,
    next: ^Entity
}
player: ^Entity

Explosion :: struct {
    x, y, dx, dy: f32,
    r, g, b, a: i32,
    next: ^Explosion,
}

Debris :: struct {
    x, y, dx, dy: f32,
    life: i32,
    rect: sdl.Rect,
    texture: sdl.Texture,
}

Stage :: struct {
    fighterHead, bulletHead: Entity, 
    fighterTail, bulletTail: ^Entity,
}
stage: ^Stage

bulletTexture, enemyTexture,
playerTexture, alienBulletTexture: ^sdl.Texture

enemySpawnTimer, stageResetTimer: u32