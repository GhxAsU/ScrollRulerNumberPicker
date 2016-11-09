//
//  ViewController.swift
//  ScrollRulerNumberPicker
//
//  Created by Chen on 2016/11/8.
//  Copyright © 2016年 Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        self.label.frame = CGRect(x: 20, y: 60, width: UIScreen.main.bounds.size.width - 40, height: 20)
        self.view.addSubview(self.label)

        let picker = ScrollRulerNumberPicker(frame: CGRect(x: 20, y: 100, width: 280, height: 80))
        picker.delegate = self
        self.view.addSubview(picker)

        self.label.text = "\(picker.pickerValue)"

        /*DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+4.0, execute: {
            x.setPickerValue(value: 100, animated: true)
        })*/

        /*DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            picker.redLineColor = UIColor.purple
        })*/
    }


    lazy var label: UILabel = {
        var x = UILabel(frame: CGRect.zero)
        x.textColor = UIColor.black
        x.font = UIFont.systemFont(ofSize: 16)
        x.textAlignment = .center
        return x
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: ScrollRulerNumberPickerDelegate {
    func numberPicker(numberPicker: ScrollRulerNumberPicker, updateValue value: CGFloat) {
        self.label.text = "\(value)"
    }
    
    func numberPicker(numberPicker: ScrollRulerNumberPicker, textForValue value: CGFloat) -> String {
        return String(format: "%.0f", value)
    }
}

