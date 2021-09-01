module main

import animations
import gg
import gx
import rand

struct AnimationOption {
   animation_method fn (f64) f64
   animation_name string
}
const (
   animations_ = [
      AnimationOption { animations.linear, "Linear"},
      AnimationOption { animations.ease_in_sine, "Ease In Sine"},
      AnimationOption { animations.ease_out_sine, "Ease Out Sine"},
      AnimationOption { animations.ease_in_out_sine, "Ease In Out Sine"},
      AnimationOption { animations.ease_in_cubic, "Ease In Cubic"},
      AnimationOption { animations.ease_out_cubic, "Ease Out Cubic"},
      AnimationOption { animations.ease_in_out_cubic, "Ease In Out Cubic"},
      AnimationOption { animations.ease_in_quint, "Ease In Quint"},
      AnimationOption { animations.ease_out_quint, "Ease Out Quint"},
      AnimationOption { animations.ease_in_out_quint, "Ease In Out Quint"},
      AnimationOption { animations.ease_in_circ, "Ease In Circ"},
      AnimationOption { animations.ease_out_circ, "Ease Out Circ"},
      AnimationOption { animations.ease_in_out_circ, "Ease In Out Circ"},
      AnimationOption { animations.ease_in_elastic, "Ease In Elastic"},
      AnimationOption { animations.ease_out_elastic, "Ease Out Elastic"},
      AnimationOption { animations.ease_in_out_elastic, "Ease In Out Elastic"},
      AnimationOption { animations.ease_in_quad, "Ease In Quad"},
      AnimationOption { animations.ease_out_quad, "Ease Out Quad"},
      AnimationOption { animations.ease_in_quart, "Ease In Quart"},
      AnimationOption { animations.ease_out_quart, "Ease Out Quart"},
      AnimationOption { animations.ease_in_out_quart, "Ease In Out Quart"},
      AnimationOption { animations.ease_in_expo, "Ease In Exponential"},
      AnimationOption { animations.ease_out_expo, "Ease Out Exponential"},
      AnimationOption { animations.ease_in_out_expo, "Ease In Out Exponential"},
      AnimationOption { animations.ease_in_back, "Ease In Back"},
      AnimationOption { animations.ease_out_back, "Ease Out Back"},
      AnimationOption { animations.ease_in_out_back, "Ease In Out Back"},
      AnimationOption { animations.ease_in_bounce, "Ease In Bounce"},
      AnimationOption { animations.ease_out_bounce, "Ease Out Bounce"},
      AnimationOption { animations.ease_in_out_bounce, "Ease In Out Bounce"},
   ]
)

struct ExampleData {
   min_speed i64 = 200
   max_speed i64 = 10000
mut:
   x f32
   ctx &gg.Context
   current_animation int 
   animation_id u64
   ani_manager &animations.AnimationManager
   current_speed i64 = 3000
   dark_background bool = true
   text_color gx.Color = gx.white
   cube_color gx.Color = gx.red
}

fn keydown_event(key gg.KeyCode, m gg.Modifier, mut data ExampleData) {
   mut altered := false
   match key {
      .left {
         altered = true
         data.current_animation -= 1
      }
      .right {
         altered = true
         data.current_animation += 1
      }
      .up {
         altered = true
         data.current_speed += 100
      }
      .down {
         altered = true
         data.current_speed -= 100
      }
      .d {
         data.dark_background = !data.dark_background
         data.ctx.set_bg_color(if data.dark_background { gx.black } else { gx.white })
         data.text_color = if data.dark_background { gx.white } else { gx.black }
      }
      .r {
         data.cube_color = gx.Color {
            r: rand.byte()
            g: rand.byte()
            b: rand.byte()
         }
      }
      else {}
   } 
   if altered {
      if data.current_speed > data.max_speed {
         data.current_speed = data.max_speed
      } else if data.current_speed < data.min_speed {
         data.current_speed = data.min_speed
      }
      if data.current_animation < 0 {
         data.current_animation = animations_.len - 1
      } else if data.current_animation >= animations_.len {
         data.current_animation = 0
      }
      data.set_animation(data.current_animation)
   }
}

fn update(data &ExampleData) {
   data.ctx.begin()
   data.ctx.draw_rect(data.x, 630 - 180, 90, 90, data.cube_color)

   // Wall of Text
   data.ctx.draw_text(1280 / 2, 50, "vanimations example", gx.TextCfg {
      color: data.text_color
      size: 64
      align: .center
      bold: true
   })
   data.ctx.draw_text(1280 / 2, 160, "Current Animation:", gx.TextCfg {
      color: data.text_color
      size: 36
      align: .center
   })
   data.ctx.draw_text(1280 / 2, 200, animations_[data.current_animation].animation_name, gx.TextCfg {
      color: data.text_color
      size: 36
      align: .center
   })
   data.ctx.draw_text(1280 / 2, 250, "Current Speed: " + data.current_speed.str() + "ms", gx.TextCfg {
      color: data.text_color
      size: 36
      align: .center
   })
   data.ctx.draw_text(1280 / 2, 300, "Use Left Arrow and Right Arrow to swap animation.", gx.TextCfg {
      color: data.text_color
      size: 36
      align: .center
   })
   data.ctx.draw_text(1280 / 2, 350, "Up and down to change speed.", gx.TextCfg {
      color: data.text_color
      size: 36
      align: .center
   })

   // Small special hints ;3
   data.ctx.draw_text(0, 720, "Press d to toggle between light and dark mode.", gx.TextCfg {
      color: data.text_color
      size: 16
      align: .left
      vertical_align: .bottom
   })

   data.ctx.draw_text(1280, 720, "Press r to randomise cube color.", gx.TextCfg {
      color: data.text_color
      size: 16
      align: .right
      vertical_align: .bottom
   })

   data.ctx.end()
}

fn (mut data ExampleData) set_animation(id int){
   if id > -1 && animations_.len > id {
      // Valid Animation
      if data.animation_id != 0 {
         data.ani_manager.cancel(data.animation_id)
      }
      data.animation_id = data.ani_manager.add(mut data.x, 200, 1080, data.current_speed, animations_[id].animation_method, true)
      data.current_animation = id
   }
}

fn main(){
   mut data := ExampleData{
      ani_manager: animations.new_animation_manager(true)
      ctx: voidptr(0)
   }
   ctx := gg.new_context(gg.Config{width: 1280, height: 720, user_data: &data, font_size: 36, create_window: true, window_title: "VAnimations Example", keydown_fn: keydown_event, frame_fn: update})
   data.ctx = ctx
   go data.ani_manager.loop()
   data.set_animation(0)
   data.ctx.run()
}