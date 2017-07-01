    //  ViewController.swift

    import UIKit
    import FBAudienceNetwork
    import GoogleMobileAds
    
    //class ViewController: UIViewController, UIWebViewDelegate, FBInterstitialAdDelegate {
    class ViewController: UIViewController, UIWebViewDelegate, FBInterstitialAdDelegate, GADInterstitialDelegate {

        @IBOutlet weak var myWebView: UIWebView!
        
        //appcode.com/facebook-ads-integration ////////////////////////////////////////////////
        @IBOutlet weak var viewAdContainer: UIView!
        @IBOutlet weak var lblAdTitle: UILabel!
        @IBOutlet weak var lblAdBody: UILabel!
        @IBOutlet weak var imgAdIcon: UIImageView!
        @IBOutlet weak var btnAdAction: UIButton!
        @IBOutlet weak var lblSocialContext: UILabel!
        
        var fullScreenAd:FBInterstitialAd!
        var interstitial:GADInterstitial?
        var facebook_placement_id = ""
        var banner_ad_unit_id = ""
        
        required init(coder aDecoder: NSCoder){
            super.init(coder: aDecoder)!
            log(msg: "init(coder)")
            
            //ads id's
            //let facebook_app_id = "1331514456968402"
            
            facebook_placement_id = "1331514456968402_1331553776964470"
            banner_ad_unit_id = "ca-app-pub-1068442097767769/3963848334"
            
            if(Int(arc4random_uniform(2)) != 0){
                //facebook_placement_id = "1879320152282480_1879320752282420"
                //banner_ad_unit_id = "ca-app-pub-1933379640772575/1620240847"
            }
            
            FBAdSettings.setLogLevel(FBAdLogLevel.log)
            //FBAdSettings.addTestDevice(HASHED)
            //[FBAdSettings addTestDevice:@"HASHED_ID"]
            
        }

        func loadNativeAd() {
            fullScreenAd = FBInterstitialAd(placementID: facebook_placement_id)
            fullScreenAd.delegate = self
            fullScreenAd.load()
        }
        
        func interstitialAdDidLoad(interstitialAd: FBInterstitialAd){
            log(msg: "interstitialAdDidLoad")
            interstitialAd.show(fromRootViewController: self)
        }
        
        func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error){
            //log(msg: "print(error)")
            //print(error);
            log(msg: "print(error) END")
            
            //from adMOB:
            if (interstitial?.isReady)!{
                interstitial?.present(fromRootViewController: self)
            }
            createAndLoadInterstitial()
        }
        
        func interstitialAdDidClick(_ interstitialAdd: FBInterstitialAd) {
            print("Did tap on the ad")
        }
        func interstitialAdDidClose(_ interstitialAdd: FBInterstitialAd) {
            print("Did close ad")
        }
        ////////////////////////////////////////////////////////////////////////
        
        func createAndLoadInterstitial(){
            log(msg: "adMOB createAndLoadIntersttial")
            interstitial = GADInterstitial(adUnitID: banner_ad_unit_id)
            
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID ]
            
            interstitial?.delegate = self;
            log(msg: "adMOB load")
            interstitial?.load(request)
            log(msg: "adMOB loaded")
        }
        
        let url = NSURL (string: "http://would-you-rather.tk")
        
        override func viewDidLoad() {
            log(msg: "viewDidLoad")
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            
            let requestObj = URLRequest(url: url as! URL)
            myWebView.delegate = self
            myWebView.loadRequest(requestObj)
            
            //loadJS()
            
            createAndLoadInterstitial()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func webViewDidFinishLoad(_ myWebView: UIWebView) {
            loadJS()
        }
        
        func loadJS(){
            log(msg: "did finish")
            
            let js = "; function handler(){"
                + "this.share = function(img,key){"
                + "   window.location = 'device://share?img=' + img + '&key=' + key"
                + "}; "
                + "this.loadAd = function(){"
                + "   window.location = 'device://loadAd'"
                + "}; "            //+ "this.loadKey = function(){}; "
                //+ "this.newKey = function(){}; "
                //+ "this.firstTimeOk = function(){}; "
                //+ "this.loadDefault = function(){}; "
                //+ "this.save = function(){}; "
                //+ "this.askPhone = function(){}; "
                //+ "this.pickIconImage = function(){}; "
                //+ "this.getKeyData = function(){}; "
                //+ "this.error = function(){}; "
                //+ "this.log = function(){}; "
                //+ "this.close = function(){}; "
                //+ "this.showStars = function(){}; "
                //+ "this.simpleRequest = function(){}; "
                //+ "this.saveLocalStorage = function(){}; "
                //+ "this.permissionsRedirection = function(){}; "
                + "}; "
                + "window.Device = new handler(); "
                + "console.log('works'); "
            
            let when = DispatchTime.now() + 5 // change to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.log(msg: "TIMEOUT")
                self.myWebView.stringByEvaluatingJavaScript(from: js)
            }
        }
        
        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType ) -> Bool {
            log(msg: "webView")
            let url = request.url!
            
            if (url.scheme == "device") {
                log(msg: "request.url.host " + url.host!)
                
                if(url.host == "share"){
                    let img = url.query!.components(separatedBy: "=")[1].components(separatedBy: "&")[0];
                    let url = url.query!.components(separatedBy: "=")[2].components(separatedBy: "&")[0];
                    
                    shareImage(img: img, url: url);
                    
                } else if(url.host == "loadAd"){
                    loadNativeAd();
                }
                
                return false;
            }
            return true
        }
        
        func shareImage(img : String, url : String) {
            log(msg: "shareImage "+img)
            let arr = url.components(separatedBy: "/")
            let key = arr.last!
            
            //decode
            let paddedLength = img.characters.count + (4 - (img.characters.count % 4))
            let correct = img.padding(toLength: paddedLength, withPad:"=", startingAt:0)
            
            let dataDecoded:NSData = NSData(base64Encoded: correct, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded as Data)!
            
            //save
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // create a name for your image
            let fileURL = documentsDirectoryURL.appendingPathComponent(key+".png")
            
            //delete file
            do{
                try FileManager.default.removeItem(atPath: fileURL.path)
            }catch{
                //
            }
            
            //if !FileManager.default.fileExists(atPath: fileURL.path) {
            if let png = UIImagePNGRepresentation(decodedimage){
                do{
                    try png.write(to: fileURL)
                    log(msg: "Image Added Successfully")
                }catch{
                    log(msg: "catch error")
                }
            }else {
                log(msg: "can't png")
            }
            
            //load
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            
            if let dirPath = paths.first{
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(key+".png")
                if let image = UIImage(contentsOfFile: imageURL.path){
                    
                    //share
                    let vc = UIActivityViewController(activityItems: [url, image], applicationActivities: nil)
                    vc.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.print]
                    //iPad box popup:
                    vc.popoverPresentationController?.sourceView = self.view
                    self.present(vc, animated: true, completion: nil)
                    
                }
            }
            
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
        
        func log(msg: String){
            print(msg)
            NSLog(msg)
        }
        
    }
    
