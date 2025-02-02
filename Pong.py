WHITE = (255,255,255)
BLACK = (0,0,0)
RED = (255,0,0)
YELLOW = (255,255,0)
GREEN = (0,175,0)
BLUE = (0,0,255)
LIGHTBLUE = (100, 150, 255)
ORANGE = (255,125,0)
GRAY = (100,100,100)

PADDLE_HEIGHT = 150
PADDLE_WIDTH = 30
SCREEN_HEIGHT = 800
SCREEN_WIDTH = 1000

import pygame 
import sys
import random
import math
import keyboard

class Player(pygame.sprite.Sprite):
    def  __init__(self, size, keys, color, x):
        pygame.sprite.Sprite.__init__(self)
        self.cx = x
        self.cy = 400
        self.controls = keys
        self.color = color
        self.speed = 1


        self.width = size[0]
        self.height = size[1]

        self.direction = 1
        self.destination = SCREEN_WIDTH/2
    def moveup(self):
        if self.cy - self.speed >= self.height/2:
            self.cy -= self.speed
    def movedown(self):
        if self.cy + self.speed <= SCREEN_HEIGHT - self.height/2:
            self.cy += self.speed
    def update(self):
        if self.controls == "tweaking computer":
            num = random.randint(1, 100)
            if num == 1:
                self.direction = -1 * self.direction
            if self.direction == 1:
                self.moveup()
            else:
                self.movedown()
        if self.controls == "stupid computer":
            if self.cy > self.destination:
                self.moveup()
            elif self.cy < self.destination:
                self.movedown()
            else:
                self.destination = random.randint(self.height/2, SCREEN_HEIGHT - self.height/2)
        else:
            if keyboard.is_pressed(self.controls[0]):
                self.moveup()
            if keyboard.is_pressed(self.controls[1]):
                self.movedown()

class Ball(pygame.sprite.Sprite):
    def __init__(self, size):
        pygame.sprite.Sprite.__init__(self)
        self.reset()
        self.size = size
        self.scores = [0,0]

    def reset(self):
        self.yspeed = random.randint(-40,40)/100
        self.xspeed = random.randint(10,40)/100
        self.xdirect = random.randrange(-1,2,2)
        #self.ydirect = random.randrange(-1,2,2)
        self.cx = 500
        self.cy = 400

    def bounce(self):
        self.xdirect = -(self.xdirect)
        #self.ydirect = -(self.ydirect)

    def update(self):
        self.cx += self.xdirect * self.xspeed
        self.cy += self.yspeed#* self.ydirect
        if self.collideWall():
            self.yspeed = -(self.yspeed)
        if self.cx < 0:
            self.reset()
            self.scores[1] = self.scores[1] + 1
        elif self.cx > SCREEN_WIDTH:
            self.reset()
            self.scores[0] = self.scores[0]+1
        self.yspeed *= 1.00005
        self.xspeed *= 1.00005

    def checkPaddleCollisions(self, player):
        if player.cx < SCREEN_WIDTH/2:
            x = player.cx + player.width/2
        else:
            x = player.cx - player.width/2
        y1 = player.cy - player.height/2
        y2 = player.cy + player.height/2
        if (self.cx - x <= self.size and self.cx - x >= -self.size) and (self.cy >= y1 and self.cy <= y2) and ((player.cx < SCREEN_WIDTH/2 and self.xdirect < 0) or (player.cx >= SCREEN_WIDTH/2 and self.xdirect > 0)):
            self.bounce()
        # without the last condition, if you move your collision hitbox onto the ball, the ball bounces indefinitely !!!!!
        
    def collideWall(self):
        return (self.cy < self.size or self.cy > SCREEN_HEIGHT - self.size)


class Game():
    def __init__(self):
        self.screen_height = SCREEN_HEIGHT
        self.screen_width = SCREEN_WIDTH

        self.game_over = False


        pygame.init()
        self.screen_size = (self.screen_width,self.screen_height)
        self.screen = pygame.display.set_mode(self.screen_size)
        pygame.display.set_caption("Pong")

        self.font = pygame.font.SysFont('Arial', 25, True, False)

        self.all_sprites = pygame.sprite.Group()
        self.players = pygame.sprite.Group()
        self.p_left = Player((PADDLE_WIDTH, PADDLE_HEIGHT), ('w', 's'), BLUE, 30)
        self.p_right = Player((PADDLE_WIDTH, PADDLE_HEIGHT), 'tweaking computer', RED, self.screen_width-30) # change to ('up', 'down') for 2 player gameplay
        self.all_sprites.add(self.p_left)
        self.all_sprites.add(self.p_right)
        self.players.add(self.p_left)
        self.players.add(self.p_right)

        self.ball = Ball(20)
        self.all_sprites.add(self.ball)

        self.computer_direction = 1

    def run(self):
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    sys.exit()
            
            self.screen.fill(BLACK)

            self.all_sprites.update()

            for player in self.players:
                self.ball.checkPaddleCollisions(player)


            p1_score_text = self.font.render(str(self.ball.scores[0]), True, BLUE)
            p2_score_text = self.font.render(str(self.ball.scores[1]), True, RED)

            self.screen.blit(p1_score_text, [400, 20])
            self.screen.blit(p2_score_text, [600, 20])

            pygame.draw.circle(self.screen, WHITE, (self.ball.cx, self.ball.cy), self.ball.size)
            pygame.draw.circle(self.screen, GREEN, (int(self.ball.cx + 70*self.ball.xspeed*self.ball.xdirect), int(self.ball.cy + 70*self.ball.yspeed)), self.ball.size/4)
            
            for player in self.players:
                pygame.draw.rect(self.screen, player.color, [player.cx-15, player.cy-PADDLE_HEIGHT/2, 30, PADDLE_HEIGHT])

            pygame.display.flip()

game = Game()
game.run()