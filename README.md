# VAnimations

A library for animating single variables over time using easings methods or own methods.

This system works by animating single variables over time using an AnimationManager. For now only f32 values can be used, because Generics for some reason refuse to participate.

## Install
VAnimations is on vpm under `Mondanzo.animations` therefore you can just install it using `v install Mondanzo.animations`. Then you can import it in your project using `import mondanzo.animations`.

## Example

```v
module main

import time
import mondanzo.animations // Import the module

fn main(){
  // Create a new AnimationManager
  manager := animations.new_animation_manager(true)

  // Start the AnimationManager loop in a new thread
  go manager.loop()

  mut value := 0

  // Add a new task to the animation manager
  task_id := manager.add(mut value, 0, 100, 4000, animations.ease_out_sine, false)

  for i := 0; i < 4; i += 1 {
    println("Value: $value")
    time.sleep(500)
  }

  // Cancel the running task.
  manager.cancel(task_id)
}
```

To get started just import the library and create a new AnimationManager using `animations.new_animation_manager(true)`.

The documentation can be accessed at [https://mondanzo.github.io/vanimations/](https://mondanzo.github.io/vanimations/). Generated using vdoc.

Please note that this project is still WIP.

Feel free to report any issues or create suggestions.
