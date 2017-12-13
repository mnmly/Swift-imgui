#  Swift-imgui

*Personal WIP*

### [Immediate mode GUI Library](https://github.com/ocornut/imgui/) from [Omar Cornut](https://github.com/ocornut) wrapped for use with Swift, inspired from [Cinder-ImGui](https://github.com/simongeilfus/Cinder-ImGui)

![](http://c.mnmly.com/kRxd/hello-imgui-swift.gif)

#### Installation with Carthage

Add following to `Cartfile`:

```
github "mnmly/Swift-imgui" "master"
```

Then follow the standard `carthage` installation process.

#### Usage

```swift
import UIKit
import ImGui

class ViewController: UIViewController {
    
    var myView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var viewOffset: CGPoint = CGPoint.zero
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        myView.backgroundColor = UIColor(hue:0.592, saturation:0.904, brightness:0.980, alpha:1.000)
        
        myView.center = view.center
        
        view.addSubview(myView)
        
        // Initialize with Metal Graphics API for drawing
        ImGui.initialize(.metal)
        
        if let vc = ImGui.vc {
            // Add viewController and view to scene
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: view.frame.height * 0.7, width: view.frame.width, height: view.frame.height * 0.3)
        }
        
        ImGui.draw { (imgui) in
            
            // Setting Window Position and window size
            imgui.setNextWindowPos(CGPoint.zero, cond: .always)
            imgui.setNextWindowSize(self.view.frame.size)

            imgui.begin("Hello ImGui on Swift")

            // Setting the font scale
            imgui.setWindowFontScale(UIScreen.main.scale)
            
            
            // When button is clicked...
            if imgui.button("rotate me") {
                // rotate me
                self.myView.transform = CGAffineTransform.identity
                UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.9, animations: {
                    self.myView.transform = CGAffineTransform.init(rotationAngle: 180.0)
                }).startAnimation()
            }
            
            imgui.sliderFloat("cornerRadius", v: &self.myView.layer.cornerRadius, minV: 0.0, maxV: 10.0)
            imgui.sliderFloat2("offset", v: &self.viewOffset, minV: -100.0, maxV: 100.0)
            imgui.sliderFloat2("size", v: &self.myView.bounds.size, minV: 5.0, maxV: 100.0)
            imgui.colorEdit("backgroundColor", color: &(self.myView.backgroundColor)!)
            imgui.end()
            
            var center = self.view.center
            center.x += self.viewOffset.x
            center.y += self.viewOffset.y
            self.myView.center = center
        }
    }
}
```

#### Todo
* Keyboard Events on iOS
* Exposing more API to Swift


ImGui Credits (from [ImGui](https://github.com/ocornut/imgui/) README)
-------

---

<sub>(ImGui is free but Omar needs your support to sustain development and maintenance. If you work for a company, please consider financial support)</sub>

[![Patreon](https://cloud.githubusercontent.com/assets/8225057/5990484/70413560-a9ab-11e4-8942-1a63607c0b00.png)](http://www.patreon.com/imgui) [![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5Q73FPZ9C526U)


ImGui is a bloat-free graphical user interface library for C++. It outputs vertex buffers that you can render in your 3D-pipeline enabled application. It is portable, renderer agnostic and self-contained (no external dependencies). It is based on an "immediate mode" graphical user interface paradigm which enables you to build user interfaces with ease.

ImGui is designed to enable fast iteration and empower programmers to create content creation tools and visualization/debug tools (as opposed to UI for the average end-user). It favors simplicity and productivity toward this goal, and thus lacks certain features normally found in more high-level libraries.

ImGui is particularly suited to integration in realtime 3D applications, fullscreen applications, embedded applications, games, or any applications on consoles platforms where operating system features are non-standard.

---

Developed by [Omar Cornut](http://www.miracleworld.net) and every direct or indirect contributors to the GitHub. The early version of this library was developed with the support of [Media Molecule](http://www.mediamolecule.com) and first used internally on the game [Tearaway](http://tearaway.mediamolecule.com). 

I first discovered imgui principles at [Q-Games](http://www.q-games.com) where Atman had dropped his own simple imgui implementation in the codebase, which I spent quite some time improving and thinking about. It turned out that Atman was exposed to the concept directly by working with Casey. When I moved to Media Molecule I rewrote a new library trying to overcome the flaws and limitations of the first one I've worked with. It became this library and since then I have spent an unreasonable amount of time iterating on it. 

Embeds [ProggyClean.ttf](http://upperbounds.net) font by Tristan Grimmer (MIT license).

Embeds [stb_textedit.h, stb_truetype.h, stb_rectpack.h](https://github.com/nothings/stb/) by Sean Barrett (public domain).

Inspiration, feedback, and testing for early versions: Casey Muratori, Atman Binstock, Mikko Mononen, Emmanuel Briney, Stefan Kamoda, Anton Mikhailov, Matt Willis. And everybody posting feedback, questions and patches on the GitHub.

Ongoing ImGui development is financially supported on [**Patreon**](http://www.patreon.com/imgui).

Double-chocolate sponsors:
- Media Molecule
- Mobigame
- Insomniac Games (sponsored the gamepad/keyboard navigation branch)
- Aras Pranckevičius

Salty caramel supporters:
- Jetha Chan, Wild Sheep Studio, Pastagames, Mārtiņš Možeiko, Daniel Collin, Recognition Robotics, Chris Genova, ikrima, Glenn Fiedler, Geoffrey Evans, Dakko Dakko.

Caramel supporters:
- Michel Courtine, César Leblic, Dale Kim, Alex Evans, Rui Figueira, Paul Patrashcu, Jerome Lanquetot, Ctrl Alt Ninja, Paul Fleming, Neil Henning, Stephan Dilly, Neil Blakey-Milner, Aleksei, NeiloGD, Justin Paver, FiniteSol, Vincent Pancaldi, James Billot, Robin Hübner, furrtek, Eric, Simon Barratt, Game Atelier, Julian Bosch, Simon Lundmark, Vincent Hamm, Farhan Wali, Jeff Roberts, Matt Reyer, Colin Riley, Victor Martins, Josh Simmons, Garrett Hoofman, Sergio Gonzales, Andrew Berridge, Roy Eltham, Game Preservation Society, [Kit framework](http://svkonsult.se/kit), Josh Faust, Martin Donlon, Quinton, Felix.

And other supporters; thanks!

License
-------

Dear ImGui is licensed under the MIT License, see LICENSE for more information.
