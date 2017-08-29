//
//  ViewController.swift
//  CurrentLocation_Leon
//
//  Created by lai leon on 2017/8/29.
//  Copyright © 2017 clem. All rights reserved.
//

import UIKit
import CoreLocation

/*使用定位的步骤：
 1.general->Linked Frameworks and Libraries导入CoreLocation.framework框架
 2.import CoreLocation
 3.然后就可以开始使用了
 */

let YHRect = UIScreen.main.bounds
let YHHeight = YHRect.size.height
let YHWidth = YHRect.size.width

class ViewController: UIViewController {
    let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 30, y: YHHeight - 100, width: YHWidth - 60, height: 80))
        button.setTitle("点击定位", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "Find my location"), for: .normal)
        button.addTarget(self, action: #selector(findLocation), for: .touchUpInside)
        return button
    }()

    let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 60, width: YHWidth - 20, height: 20))
        label.text = "未定位"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    let locationManager = CLLocationManager()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func findLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //初始化定位
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        renderView()
    }


    private func renderView() {
        //将图片用作当前view的背景
        /*
         SWIFT
         view.layer.contents = UIImage(named:"Image_Name").CGImage
         Objective-C
         view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"Image_Name"].CGImage);
         */
        self.view.layer.contents = UIImage(named: "bg")?.cgImage
        //添加毛玻璃效果
        let visual = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visual.frame = YHRect
        //visual压在最下面
        view.addSubview(visual)
        view.addSubview(button)
        view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        label.text = "ERROR:" + error.localizedDescription
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //prefer guard let than if let
        guard let newLocal = locations.first else {
            return
        }

        CLGeocoder().reverseGeocodeLocation(newLocal, completionHandler: { (placemarks, err) in
            if err != nil {
                print("reverse geocode fail: \(err!.localizedDescription)")
                return
            }

            if placemarks?.last != nil {
                //停止定位，节省电量，只获取一次定位
                manager.stopUpdatingLocation()
                //取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
                let placemark: CLPlacemark = (placemarks?.last)!
                let name = placemark.name ?? "-"
                let thoroughfare = placemark.thoroughfare ?? "-" //街道
                let subThoroughfare = placemark.subThoroughfare ?? "-"//街道相关信息，例如门牌等
                let localCity = placemark.locality ?? "-"//城市

                //别的含义
                //let location = placemark.location;//位置
                //let region = placemark.region;//区域
                //let addressDic = placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
                //let subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
                //let administrativeArea=placemark.administrativeArea; // 州
                //let subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
                //let postalCode=placemark.postalCode; //邮编
                //let ISOcountryCode=placemark.ISOcountryCode; //国家编码
                //let country=placemark.country; //国家
                //let inlandWater=placemark.inlandWater; //水源、湖泊
                //let ocean=placemark.ocean; // 海洋
                //let areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标

                self.label.text = name + thoroughfare + subThoroughfare + localCity
            }
        })
    }
}
