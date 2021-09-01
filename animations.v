module animations
// # Animations
// a module to animate individual variables.
//
// All Functions are taken from
// easings.net by Andrey Sitnik and Ivan Solovev
//

import math
import time
import rand

// a Task represententing a variable being animated.
struct AnimationTask {
mut:
	value &f32
	from f32
	to f32
	start_time i64
	duration i64
	method fn(f64) f64
   id u64
   finished bool
	loop bool
}

// The Animation manager, holding all the AnimationTasks.
// Don't directly create one but instead use new_animation_manager.
struct AnimationManager {
mut:
	tasks map[u64]AnimationTask
   clean bool = true
}
// new_animation_manager
// create a new Animation Manager.
// clean_finished_tasks bool - Determine if the AnimationTasks should be cleared once they complete.
pub fn new_animation_manager(clean_finished_tasks bool) &AnimationManager {
	return &AnimationManager {
		tasks: map[u64]AnimationTask{}
      clean: clean_finished_tasks
		stopwatch: time.StopWatch {}
	}
}

// set_clean
// set if the manager should remove finished tasks.
pub fn (mut manager AnimationManager) set_clean(clean bool){
   manager.clean = clean
}

// add
// Add a new task to the AnimationManager.
// v - a pointer to the value to animate.
// f - the value to start from.
// t - the value to animate to.
// d - the duration to take in milliseconds.
// m - the method to use. See the easing animations in this module.
// loop - should the animation be looped between from and to value
//
// Returns the id of the created task.
pub fn (mut manager AnimationManager) add(mut v &f32, f f32, t f32, d i64, m fn(f64) f64, loop bool) u64 {
   task_id := rand.u64()
	unsafe {
		manager.tasks[task_id] = AnimationTask {
			value: &v
			from: f
			to: t
			start_time: time.ticks()
			duration: d
         id: task_id
			method: m
			loop: loop
		}
	}
	return task_id
}

// cancel
// Cancels a task. This will not finish the task. It will just cancel it mid-time.
// task_id - the id of the task
//
// Returns true if deleted successfully. False otherwise
pub fn (mut manager AnimationManager) cancel(task_id u64) bool {
   if task_id in manager.tasks {
      manager.tasks.delete(task_id)
      return true
   }
   return false
}

// loop
// The loop of the AnimationManager.
// run in a separated thread using `go manager.loop()`
pub fn (mut manager AnimationManager) loop() {
	for {
		for _, mut task in manager.tasks {
         if task.finished || (time.ticks() - task.start_time) >= task.duration {
				if task.loop {
					t := task.to
					task.to = task.from
					task.from = t
					task.start_time = time.ticks()
					continue
				}
            if manager.clean {
               manager.tasks.delete(task.id)
            } else {
               task.finished = true
            }
            continue
         }
			unsafe {
				*task.value = task.from + f32(task.method((f64(time.ticks() - task.start_time)) / f64(task.duration)) * (task.to - task.from))
			}
		}

		time.sleep(time.millisecond * 5)
	}
}

// Linear
pub fn linear(x f64) f64 {
	return x
}

// Sine

pub fn ease_in_sine(x f64) f64 {
     return 1 - math.cos((x * math.pi) / 2)
}

pub fn ease_out_sine(x f64) f64 {
   return math.sin((x * math.pi) / 2)
}

pub fn ease_in_out_sine(x f64) f64 {
   return -(math.cos(math.pi * x) - 1) / 2
}

// Cubic

pub fn ease_in_cubic(x f64) f64 {
   return x * x * x
}

pub fn ease_out_cubic(x f64) f64 {
   return 1 - math.pow(1 - x, 3)
}

pub fn ease_in_out_cubic(x f64) f64 {
   if x < 0.5 {
      return 4 * x * x * x
   } else {
      return 1 - math.pow(-2 * x + 2, 3) / 2
   }
}

// Quint

pub fn ease_in_quint(x f64) f64 {
	return x * x * x * x * x
}

pub fn ease_out_quint(x f64) f64 {
	return 1 - math.pow(1 - x, 5)
}

pub fn ease_in_out_quint(x f64) f64 {
	if x < 0.5 {
		return 16 * x * x * x * x * x
	} else {
		return 1 - math.pow(-2 * x + 2, 5) / 2
	}
}

// Circ

pub fn ease_in_circ(x f64) f64 {
	return 1 - math.sqrt(1 - math.pow(x, 2))
}

pub fn ease_out_circ(x f64) f64 {
	return math.sqrt(1 - math.pow(x - 1, 2))
}

pub fn ease_in_out_circ(x f64) f64 {
	if x < 0.5 {
		return f64(1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
	} else {
		return f64(math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
	}
}

// Elastic

pub fn ease_in_elastic(x f64) f64 {
	c4 := (2 * math.pi) / 3

	if x == 0 {
		return 0
	} else if x == 1 {
		return 1
	} else {
		return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
	}
}

pub fn ease_out_elastic(x f64) f64 {
	c4 := (2 * math.pi) / 3

	if x == 0 {
		return 0
	} else if x == 1 {
		return 1
	} else {
		return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
	}
}

pub fn ease_in_out_elastic(x f64) f64 {
	c5 := (2 * math.pi) / 4.5
	if x == 0 {
		return 0
	} else if x == 1 {
		return 1
	} else if x < 0.5 {
		return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
	} else {
		return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
	}
}

// Quad

pub fn ease_in_quad(x f64) f64 {
	return x*x
}

pub fn ease_out_quad(x f64) f64 {
	return 1 - (1 - x) * (1 - x)
}

pub fn ease_in_out_quad(x f64) f64 {
	if x < 0.5 {
		return 2 * x * x
	} else {
		return f64(1 - math.pow(-2 * x + 2, 2) / 2)
	}
}

// Quart

pub fn ease_in_quart(x f64) f64 {
	return x * x * x * x
}

pub fn ease_out_quart(x f64) f64 {
	return 1 - math.pow(1 - x, 4)
}

pub fn ease_in_out_quart(x f64) f64 {
	if x < 0.5 {
		return 8 * x * x * x * x
	} else {
		return 1 - math.pow(-2 * x + 2, 4) / 2
	}
}

// Expo

pub fn ease_in_expo(x f64) f64 {
	if x == 0 {
		return 0
	} else {
		return math.pow(2, 10 * x - 10)
	}
}

pub fn ease_out_expo(x f64) f64 {
	if x == 1 {
		return 1
	} else {
		return 1 - math.pow(2, -10 * x)
	}
}

pub fn ease_in_out_expo(x f64) f64 {
	if x == 0 {
		return 0
	} else if x == 1 {
		return 1
	} else if x < 0.5 {
		return math.pow(2, 20 * x - 10) / 2
	} else {
		return (2 - math.pow(2, -20 * x + 10)) / 2
	}
}

// Back
pub fn ease_in_back(x f64) f64 {
	c1 := 1.70158
	c3 := c1 + 1
	return c3 * x * x * x - c1 * x * x
}

pub fn ease_out_back(x f64) f64 {
	c1 := 1.70158
	c3 := c1 + 1

	return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
}

pub fn ease_in_out_back(x f64) f64 {
	c1 := 1.70158
	c2 := c1 * 1.525

	if x < 0.5 {
		return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
	} else {
		return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
	}
}

// Bounce
pub fn ease_in_bounce(x f64) f64 {
	return 1 - ease_out_bounce(1 - x)
}

// TODO: Fix Ease Out Bounce doing funky things

pub fn ease_out_bounce(y f64) f64 {
	mut x := y
	n1 := 7.5625
	d1 := 2.75

	if x < (1 / d1) {
		return n1 * x * x
	} else if x < (2 / d1) {
		x -= 1.5 / d1
		return n1 * x * x + 0.75
	} else if x < (0.25 / d1) {
		x -= 2.25 / d1
		return n1 * x * x + 0.9375
	} else {
		x -= 2.625 / d1
		return n1 * x * x + 0.984375
	}
}

pub fn ease_in_out_bounce(y f64) f64 {
	mut x := y
	if x < 0.5 {
		return (1 - ease_out_bounce(1 - 2 * x)) / 2
	} else {
		return (1 + ease_out_bounce(2 * x - 1)) / 2
	}
}
