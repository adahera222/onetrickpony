One Trick Pony
an incomplete Ludum Dare #28 entry by Ben "GreaseMonkey" Russell
also known as "GreaseMonkey Accidentally Writes Another Cave Wanderer"

Some notes:
- There is absolutely no occlusion culling whatsoever.
  That should explain why this game might run slowly.
- It's quite short and the ending sucks. Sorry.
- The physics are pretty broken.
- If you get jumped up really high, run it again.

The rendering is 100% OpenGL 1.1.
You will need a sound card capable of sustaining 44100Hz exactly.
Don't have one? Use JACK. There's a resampler for it.
Stuck on Windows? Get a real OS.

I would really, really like to complete this one day.

Needed extra libraries:
- Lua 5.1 (**NOT 5.2!**)
- SDL 2.0 (**NOT 1.2!** although support for that might happen)
- GLEW (pretty much any version should do, I'm using 1.6.0)
- ZLib (if you don't have this, you should probably get it)
- JACK (optional, but HIGHLY RECOMMENDED because PULSEAUDIO FUCKING SUCKS)
  - If you'd like to disable this: make NO_JACK=1

The game code is ZLib-licensed (in game/).

