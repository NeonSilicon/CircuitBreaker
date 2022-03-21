//
//  AudioUnitViewController.swift
//  CircuitBreaker AU
//
//  Created by Robert Abernathy on 3/17/22.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    
    // The addresses should be done in a file that the can be read from in common for the AU and VC.
    // Since this is a very simple demo, we can do it in each file.
    static let clip_level_address: AUParameterAddress = 0
    
    var audioUnit: AUAudioUnit? {
        didSet {
            /*
             We may be on a dispatch worker queue processing an XPC request at
             this time, and quite possibly the main queue is busy creating the
             view. To be thread-safe, dispatch onto the main queue.
             
             It's also possible that we are already on the main queue, so to
             protect against deadlock in that case, dispatch asynchronously.
             */
            if self.isViewLoaded {
                if Thread.isMainThread {
                    self.connectViewWithAU()
                } else {
                    DispatchQueue.main.async {
                        self.connectViewWithAU()
                    }
                }
            }
        }
    }
    
    // This var can be used to get to methods and parameters that are specific to the CicruitBreaker AU.
    public var circuitBreakerAudioUnit: CircuitBreaker_AUAudioUnit? {
        get {
            return audioUnit as? CircuitBreaker_AUAudioUnit
        }
    }
    
    @IBOutlet weak var clip_level_display: UILabel!
    @IBOutlet weak var clip_level_slider: UISlider!
    @IBAction func do_clip_level(_ sender: Any) {
    
        let value = clip_level_slider.value
        update_clip_level_display()
        
        if clip_level_parameter?.value != AUValue(value) {
            clip_level_parameter?.value = AUValue(value)
        }
    }
    
    func update_clip_level_display() {
        
        let value = clip_level_slider.value
        let clip_level_text = String(format: "%.2f", value)
        
        clip_level_display.text = "Clip Level: \(clip_level_text) dB"
    }
    
    // MARK: AU Parameters
    var clip_level_parameter: AUParameter?
    
    var parameterObserverToken: AUParameterObserverToken?
    
    // The KVO Observer is added in connectViewWithAU.
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "allParameterValues" {
            
            self.loadUpdatedParameterValuesToUI()
            
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public override func viewDidLoad() {
                
        super.viewDidLoad()
        
        clip_level_slider.minimumValue = -24.0
        clip_level_slider.maximumValue = 6.0

        // If the AU isn't loaded yet, don't update the controls or connect the AU and view.
        // This will be handled instead when the factory functions sets the audioUnit parameter in this view.
        if audioUnit == nil {
            return
        }
                
        connectViewWithAU()
    }
    
    private func loadUpdatedParameterValuesToUI() {
                
        // This function is called when parameters are changed as a group and need to be updated in the UI
        DispatchQueue.main.async {
            
            if let v = self.clip_level_parameter?.value {
                self.clip_level_slider.value = (v)
                self.update_clip_level_display()
            }
        }
    }
    
    internal func connectViewWithAU() {
        
        guard let paramTree = audioUnit?.parameterTree else { return }
        
        self.clip_level_parameter = paramTree.parameter(withAddress: AudioUnitViewController.clip_level_address)
                
        // Note that the token(...) method is on AUParameterNode. An AUParmeterTree is just a top level node.
        parameterObserverToken = paramTree.token( byAddingParameterObserver: { [weak self] address, value in
                        
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                
                switch address {
                
                case strongSelf.clip_level_parameter?.address:
                    strongSelf.clip_level_slider.value = value
                    strongSelf.update_clip_level_display()
          
                default:
                    break
                }
            }
        } )
        
        // Parameter observers have been set and the au is loaded and connected to the view.
        // Now add the KVO on the allParameters var to get preset changes
        audioUnit?.addObserver(self, forKeyPath: "allParameterValues", options: NSKeyValueObservingOptions.new, context: nil)
        
        // Get the current parameters set in the UI.
        // This must be done here because the host may have loaded the state before the KVO is set.
        self.loadUpdatedParameterValuesToUI()
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        
        audioUnit = try CircuitBreaker_AUAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
}
