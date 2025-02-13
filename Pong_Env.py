from typing import Optional
import numpy as np
import gymnasium as gym
import random

TIME_SPEED = 20

class GridWorldEnv(gym.Env):

    def __init__(self):


        self._agent_location = np.array([400], dtype=np.int32)
        self._ball_pos = np.array([400, 500], dtype=np.float64)
        self._ball_veloc = np.array([-1, -1], dtype=np.float64)
        self._num_hit = 0

# Observations are dictionaries with the agent's and the target's location.
        # Each location is encoded as an element of {0, ..., `size`-1}^2
        self.observation_space = gym.spaces.Dict(
            {
                "agent": gym.spaces.Box(75, 800-75, shape=(1,), dtype=int),
                "ball-pos": gym.spaces.Box(0, 1000, shape=(2,), dtype=np.float64),
                "ball-veloc": gym.spaces.Box(-100, 100, shape=(2,), dtype=np.float64),
            }
        )



        self.action_space = gym.spaces.Discrete(3)
        self._action_to_direction = {
            # for some reason, always favors action 0
            1: np.array([1]),  # up
            0: np.array([0]),  # nothing
            2: np.array([-1]),  # down
        }
    
    def _get_obs(self):
        return {"agent": self._agent_location, "ball-pos": self._ball_pos, "ball-veloc": self._ball_veloc}
    
    def _get_info(self):
        return {"score":self._num_hit}
    
    def reset(self, seed: Optional[int] = None, options: Optional[dict] = None):
        # We need the following line to seed self.np_random
        #super().reset(seed=seed)

        self._agent_location = np.array([400], dtype=np.int32)
        self._ball_pos = np.array([400, 500], dtype=np.float64)
        #self._ball_veloc = np.array([0.2 * TIME_SPEED, -0.2 * TIME_SPEED], dtype = np.float64)
        self._ball_veloc = np.array([random.randint(20,40)/100 * random.randrange(-1,2,2) * TIME_SPEED, random.randint(20,40)/100 * random.randrange(-1,2,2) * TIME_SPEED], dtype=np.float64)
        self._num_hit = 0

        observation = self._get_obs()

        return observation, self._get_info()

    def step(self,action):
        direction = self._action_to_direction[action]
        self._agent_location = np.clip(
            self._agent_location + direction * TIME_SPEED, 75, 800-75
        )
        
        self._ball_pos[0] = self._ball_pos[0] + self._ball_veloc[0]
        self._ball_pos[1] = self._ball_pos[1] + self._ball_veloc[1]

        
    
        
        #increase speed
        #self._ball_veloc[0] = self._ball_veloc[0] * 1.00005
        #self._ball_veloc[1] = self._ball_veloc[1] * 1.00005
        
        p_x = 955
        p_y = self._agent_location[0]
        b_x = self._ball_pos[0]
        b_y = self._ball_pos[1]
        # check collisions:
        # computer
        reward = 0
        if (b_x - 20 <= p_x and b_x + 20 >= p_x) and (b_y >= p_y - 75 and b_y <= p_y + 75) and self._ball_veloc[0] > 0:
            self._ball_veloc[0] = -1 * self._ball_veloc[0]
            self._num_hit += 1
            reward = 1
        # left wall - always bounces
        if (b_x - 20 <= 30 and b_x + 20 >= 30):
            self._ball_veloc[0] = -1 * self._ball_veloc[0]
        # top wall and bottom wall
        if (b_y <= 20 or b_y >= 800 - 20):
            self._ball_veloc[1] = -1 * self._ball_veloc[1]
        
        
        terminated = (self._ball_pos[0] > 1000)
        #if terminated:
        #    reward -= 10
        #reward = self._num_hit
        truncated = False
        
        return self._get_obs(), reward, terminated, truncated, self._get_info()

gym.register(id = "gymnasium_env/PongTastic-v0",
    entry_point=GridWorldEnv,
)

def dictToTuple(d):
    return (d['agent'][0], d['ball-pos'][0], d['ball-veloc'][1], d['ball-veloc'][0], d['ball-veloc'][1])

from collections import defaultdict


class PongBot:
    def __init__(
        self,
        env: gym.Env,
        learning_rate: float,
        initial_epsilon: float,
        epsilon_decay: float,
        final_epsilon: float,
        discount_factor: float = 0.95,
    ):
        """Initialize a Reinforcement Learning agent with an empty dictionary
        of state-action values (q_values), a learning rate and an epsilon.

        Args:
            env: The training environment
            learning_rate: The learning rate
            initial_epsilon: The initial epsilon value
            epsilon_decay: The decay for epsilon
            final_epsilon: The final epsilon value
            discount_factor: The discount factor for computing the Q-value
        """
        self.env = env
        self.q_values = defaultdict(lambda: np.zeros(env.action_space.n))

        self.lr = learning_rate
        self.discount_factor = discount_factor

        self.epsilon = initial_epsilon
        self.epsilon_decay = epsilon_decay
        self.final_epsilon = final_epsilon

        self.training_error = []

    def get_action(self, obs: tuple[int, int, bool]) -> int:
        """
        Returns the best action with probability (1 - epsilon)
        otherwise a random action with probability epsilon to ensure exploration.
        """
        # with probability epsilon return a random action to explore the environment
        if np.random.random() < self.epsilon:
            return self.env.action_space.sample()
        # with probability (1 - epsilon) act greedily (exploit)
        else:
            return int(np.argmax(self.q_values[obs]))

    def update(
        self,
        obs: tuple[float, float, float, float, float],
        action: int,
        reward: int,
        terminated: bool,
        next_obs: tuple[float, float, float, float, float],
    ):
        """Updates the Q-value of an action."""
        future_q_value = (not terminated) * np.max(self.q_values[next_obs])
        temporal_difference = (
            reward + self.discount_factor * future_q_value - self.q_values[obs][action]
        )

        self.q_values[obs][action] = (
            self.q_values[obs][action] + self.lr * temporal_difference
        )
        self.training_error.append(temporal_difference)

    def decay_epsilon(self):
        self.epsilon = max(self.final_epsilon, self.epsilon - self.epsilon_decay)

import pygame
import sys
screen = pygame.display.set_mode((1000, 800))
pygame.display.set_caption("Pong")

learning_rate = 0.1
n_episodes = 100#000
start_epsilon = 1.0
epsilon_decay = start_epsilon / (n_episodes / 2)  # reduce the exploration over time
final_epsilon = 0.1


env = gym.make("gymnasium_env/PongTastic-v0")
env = gym.wrappers.RecordEpisodeStatistics(env, buffer_length=n_episodes)


agent = PongBot(
    env=env,
    learning_rate=learning_rate,
    initial_epsilon=start_epsilon,
    epsilon_decay=epsilon_decay,
    final_epsilon=final_epsilon,
)

from tqdm import tqdm

for episode in tqdm(range(n_episodes)):
    obs, info = env.reset()
    done = False

    # play one episode
    while not done:
        action = agent.get_action(dictToTuple(obs))
        next_obs, reward, terminated, truncated, info = env.step(action)

        # update the agent
        agent.update(dictToTuple(obs), action, reward, terminated, dictToTuple(next_obs))

        # update if the environment is done and the current obs
        done = terminated or truncated
        obs = next_obs
        
        screen.fill((0,0,0))
        pygame.draw.circle(screen, (255,255,255), (next_obs["ball-pos"][0], next_obs["ball-pos"][1]), 20)
        pygame.draw.rect(screen, (255,0,0), [955, next_obs["agent"][0]-75, 30, 150])
        pygame.display.flip()

    agent.decay_epsilon()
        
pygame.quit()        

print(f'Episode time taken: {env.time_queue}')
print(f'Episode total rewards: {env.return_queue}')
print(f'Episode lengths: {env.length_queue}')

from matplotlib import pyplot as plt
# visualize the episode rewards, episode length and training error in one figure
fig, axs = plt.subplots(1, 3, figsize=(20, 8))

# np.convolve will compute the rolling mean for 100 episodes

axs[0].plot(env.return_queue)
axs[0].set_title("Episode Rewards")
axs[0].set_xlabel("Episode")
axs[0].set_ylabel("Reward")

axs[1].plot(env.length_queue)#np.convolve(env.length_queue, np.ones(100))
axs[1].set_title("Episode Lengths")
axs[1].set_xlabel("Episode")
axs[1].set_ylabel("Length")

axs[2].plot(agent.training_error)
axs[2].set_title("Training Error")
axs[2].set_xlabel("Episode")
axs[2].set_ylabel("Temporal Difference")

plt.tight_layout()
plt.show()


env.close()
sys.exit()
        
        