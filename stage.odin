package main

import sdl "vendor:sdl2"
import "core:math/rand"
import "core:fmt"

initStage :: proc() {
//    stage.fighterTail = &stage.fighterHead
//    stage.bulletTail = &stage.bulletHead
    stage = new(Stage)
    playerTexture = loadTexture("gfx/playerR.png")
    alienBulletTexture = loadTexture("gfx/playerBullet.png")
    bulletTexture = loadTexture("gfx/playerBullet.png")
    enemyTexture = loadTexture("gfx/enemy.png")

    enemySpawnTimer = 1

    resetStage()
}

@(private="file")
resetStage :: proc() {
    e: ^Entity

    for stage.fighterHead.next != nil {
        e = stage.fighterHead.next
        stage.fighterHead.next=e.next
        free(e)
    }
    for stage.bulletHead.next != nil {
        e = stage.bulletHead.next
        stage.bulletHead.next=e.next
        free(e)
    }
    stage = new(Stage)
    stage.fighterTail = &stage.fighterHead
    stage.bulletTail = &stage.bulletHead

    initPlayer()
    enemySpawnTimer = 1
    stageResetTimer = FPS * 2
}

@(private="file")
initPlayer :: proc() {
    player = new(Entity)
    stage.fighterTail.next = player
    stage.fighterTail = player

    player.x = 100
    player.y = 100
    player.health = 10
    player.side = SIDE_PLAYER
    player.texture = playerTexture
    sdl.QueryTexture(player.texture, nil, nil, &player.w, &player.h)
}

gameLogic :: proc() {
    doPlayer()

    doFighters()
    
    doBullets()

    doEnemies()

    spawnEnemies()

    clipPlayer()
    
    if player == nil {
        stageResetTimer -= 1
        if stageResetTimer <= 0 {
            resetStage()
        }
    }
}

@(private="file")
doPlayer :: proc() {
    if player != nil {
        // fmt.println(player.x, " ", player.y)
        player.dx, player.dy = 0, 0

        if player.reload > 0 do player.reload-=1
        if app.keyboard[sdl.Scancode.UP] == 1 do player.dy = -PLAYER_SPEED
        if app.keyboard[sdl.Scancode.DOWN] == 1 do player.dy = PLAYER_SPEED
        if app.keyboard[sdl.Scancode.LEFT] == 1 do player.dx = -PLAYER_SPEED
        if app.keyboard[sdl.Scancode.RIGHT] == 1 do player.dx = PLAYER_SPEED
        if app.keyboard[sdl.Scancode.SPACE] == 1 && player.reload == 0 do fireBullet()
    }
}

@(private="file")
doEnemies :: proc() {
    e: ^Entity

    for e = stage.fighterHead.next; e.next!=nil; e= e.next {
        if e!=player && player!=nil {
            e.reload -=1
            if e.reload <= 0 {
                fireAlienBullet(e)
            }
        }
    }
}

@(private="file")
fireAlienBullet :: proc(e: ^Entity) {
    bullet: ^Entity

    bullet = new(Entity)
    stage.bulletTail.next =bullet
    stage.bulletTail = bullet

    bullet.x= e.x
    bullet.y = e.y
    bullet.health = 1
    bullet.texture = alienBulletTexture
    bullet.side = SIDE_ALIEN
    sdl.QueryTexture(bullet.texture, nil, nil, &bullet.w, &bullet.h)

    bullet.x += f32((e.w/2) - (bullet.w/2))
    bullet.y += f32((e.h/2) - (bullet.h/2))

    calcSlope(player.x + f32(player.w/2), player.y + f32(player.h/2), e.x, e.y, &bullet.dx, &bullet.dy)
    bullet.dx *= ALIEN_BULLET_SPEED
    bullet.dy *= ALIEN_BULLET_SPEED

    e.reload = i32(rand._system_random() % FPS *2)
}

@(private="file")
fireBullet :: proc() {
    bullet: ^Entity
    bullet = new(Entity)

    stage.bulletTail.next = bullet
    stage.bulletTail = bullet

    bullet.x = player.x
    bullet.y = player.y
    bullet.side = SIDE_PLAYER
    bullet.dx = PLAYER_BULLET_SPEED
    bullet.health = 1
    bullet.texture = bulletTexture
    sdl.QueryTexture(bullet.texture, nil, nil, &bullet.w, &bullet.h)

    bullet.y += (f32(player.h) /2.0) - (f32(bullet.h) / 2.0)

    player.reload = 8
}

@(private="file")
doBullets :: proc() {
    b, prev: ^Entity
    prev = &stage.bulletHead
    for b = stage.bulletHead.next;b!=nil;b=b.next {
        b.x += b.dx
        b.y += b.dy

        if bulletHitFighter(b) || b.x < -f32(b.w) || b.y < -f32(b.h) || b.x > SCREEN_WIDTH || b.y > SCREEN_HEIGHT {
            if b == stage.bulletTail {
                stage.bulletTail = prev
            }

            prev.next = b.next
            free(b)
            b = prev
        }
        prev = b
    }
}

@(private="file")
bulletHitFighter :: proc (b: ^Entity) -> bool {
    e: ^Entity
    for e=stage.fighterHead.next; e!=nil;e=e.next {
        if e.side !=b.side && collision(i32(b.x),i32(b.y),b.w,b.h,i32(e.x),i32(e.y),e.w,e.h) {
            b.health = 0
            e.health = 0

            return true
        }
    }
    return false
}

@(private="file")
doFighters :: proc() {
    e, prev: ^Entity

    prev = &stage.fighterHead

    for e=stage.fighterHead.next; e!=nil; e=e.next {
        e.x += e.dx
        e.y += e.dy

        if e!=player && (e.x < -f32(e.w)) {
            e.health = 0
        }
        if e.health == 0 {
            if e == player {
                player = nil
            }
            if e == stage.fighterTail {
                stage.fighterTail = prev
            }
            prev.next = e.next
            free(e)
            e = prev
        }
        prev = e
    }
}

@(private="file")
spawnEnemies :: proc() {
    enemy: ^Entity
    mrand := rand.create(u64(rand._system_random()))
    enemySpawnTimer -=1
    if enemySpawnTimer <= 0 {
        enemy = new(Entity)
        stage.fighterTail.next = enemy
        stage.fighterTail = enemy

        enemy.texture = enemyTexture
        sdl.QueryTexture(enemy.texture, nil, nil, &enemy.w, &enemy.h)
        enemy.x = SCREEN_WIDTH
        enemy.y = f32(rand.uint32(&mrand) % u32(SCREEN_HEIGHT-enemy.h))
        enemy.side = SIDE_ALIEN
        enemy.reload = i32(FPS * (1 + rand.uint32(&mrand) % 3))
        enemy.health = 1
        enemy.dx = -(2 + f32(rand.uint32(&mrand) %% 4))
        enemySpawnTimer = 30 + (rand.uint32(&mrand) %% 60)
    }
}

@(private="file")
clipPlayer :: proc() {
    if player != nil {
        if player.x < 0 do player.x = 0
        if player.y < 0 do player.y = 0
        if player.x > SCREEN_WIDTH /2 do player.x = SCREEN_WIDTH/2
        if player.y > SCREEN_HEIGHT - f32(player.h) do player.y = f32(SCREEN_HEIGHT - player.h)
    }
}