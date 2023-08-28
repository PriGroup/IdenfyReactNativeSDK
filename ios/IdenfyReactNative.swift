import Foundation
import iDenfySDK
import idenfyviews

@objc(IdenfyReactNative)
class IdenfyReactNative: NSObject {
    
    @objc(start:withResolver:withRejecter:)
    func start(_ config: NSDictionary,
               resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.run(withConfig: config, resolver: resolve, rejecter: reject)
        }
    }
    
    @objc(startFaceReAuth:withResolver:withRejecter:)
    func startFaceReAuth(_ config: NSDictionary,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.runFaceReauth(withConfig: config, resolver: resolve, rejecter: reject)
        }
    }
    
    private func run(withConfig config: NSDictionary,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let authToken = GetSdkConfig.getAuthToken(config: config)
            let idenfySettingsV2 = IdenfyBuilderV2()
                .withAuthToken(authToken)
                .build()
            
            let idenfyColorMain = UIColor(hexString: "#CCB13A")
            let idenfyColorMainDarker = UIColor(hexString: "#A8922D")
            let idenfyColorButton = UIColor(hexString: "#CCB13A")
            let backgroundColor = UIColor(hexString: "#FFE5BD")
            
            IdenfyCommonColors.idenfyMainColorV2 = idenfyColorMain
            IdenfyCommonColors.idenfyMainDarkerColorV2 = idenfyColorMainDarker
            IdenfyCommonColors.idenfyGradientColor1V2 = idenfyColorMain
            IdenfyCommonColors.idenfyGradientColor2V2 = idenfyColorMainDarker
            IdenfyCommonColors.idenfyMainDarkerColorV2 = idenfyColorMainDarker
            IdenfyCommonColors.idenfyPhotoResultDetailsCardBackgroundColorV2 = backgroundColor
            
            IdenfyToolbarUISettingsV2.idenfyDefaultToolbarBackgroundColor = idenfyColorMain

            IdenfyToolbarUISettingsV2.idenfyDefaultToolbarBackIconTintColor = IdenfyCommonColors.idenfyBlack
            IdenfyToolbarUISettingsV2.idenfyDefaultToolbarLogoIconTintColor = IdenfyCommonColors.idenfyBlack
            
            IdenfyCameraPermissionViewUISettingsV2.idenfyCameraPermissionViewGoToSettingsButtonTextColor = idenfyColorMain
            IdenfyCameraPermissionViewUISettingsV2.idenfyCameraPermissionViewBackgroundColor = idenfyColorMain
            
            
            IdenfyFaceAuthenticationInitialViewUISettingsV2.idenfyFaceAuthenticationInitialViewBackgroundColor = idenfyColorMain
            IdenfyFaceAuthenticationResultsViewUISettingsV2.idenfyFaceAuthenticationResultsViewBackgroundColor = idenfyColorMain
            IdenfyFaceCameraSessionUISettingsV2.idenfyFaceCameraPreviewSessionBackgroundColor = idenfyColorMain

            IdenfyToolbarUISettingsV2.idenfyLanguageSelectionToolbarLanguageSelectionIconTintColor = IdenfyCommonColors.idenfyBlack
            IdenfyToolbarUISettingsV2.idenfyLanguageSelectionToolbarCloseIconTintColor = IdenfyCommonColors.idenfyBlack
            
            IdenfyFaceAuthenticationInitialViewUISettingsV2.idenfyFaceAuthenticationInitialViewBackgroundColor = idenfyColorMain

            IdenfyPhotoResultViewUISettingsV2.idenfyPhotoResultViewDetailsCardTitleColor = idenfyColorButton
            
            let idenfyController = IdenfyController.shared
            idenfyController.initializeIdenfySDKV2WithManual(idenfySettingsV2: idenfySettingsV2)

            let idenfyVC = idenfyController.instantiateNavigationController()
            
            idenfyVC.modalPresentationStyle = .fullScreen

            UIApplication.shared.windows.first?.rootViewController?.present(idenfyVC, animated: true)

            handleSdkCallbacks(idenfyController: idenfyController, resolver: resolve)
            
        } catch let error as NSError {
            reject("error", error.domain, error)
            return
        } catch {
            reject("error", "Unexpected error. Verify that config is structured correctly.", error)
            return
        }
    }
    
    private func handleSdkCallbacks(idenfyController: IdenfyController, resolver resolve: @escaping RCTPromiseResolveBlock) {
        idenfyController.handleIdenfyCallbacksWithManualResults(idenfyIdentificationResult: {
            idenfyIdentificationResult
            in
            let response = NativeResponseToReactNativeResponseMapper.map(o: idenfyIdentificationResult)
            resolve(response)
        })
    }
    
    private func runFaceReauth(withConfig config: NSDictionary,
                               resolver resolve: @escaping RCTPromiseResolveBlock,
                               rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let authToken = GetSdkConfig.getAuthToken(config: config)
            let immediateRedirect = GetSdkConfig.getImmediateRedirectFromConfig(config: config)
            let idenfyFaceAuthUISettings = GetSdkConfig.getFaceAuthSettingsFromConfig(config: config)
            
            let idenfyController = IdenfyController.shared
            let faceReauthenticationInitialization = FaceAuthenticationInitialization(authenticationToken: authToken, withImmediateRedirect: immediateRedirect, idenfyFaceAuthUISettings: idenfyFaceAuthUISettings)
            idenfyController.initializeFaceAuthentication(faceAuthenticationInitialization: faceReauthenticationInitialization)
            
            let idenfyVC = idenfyController.instantiateNavigationController()
            
            idenfyVC.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.windows.first?.rootViewController?.present(idenfyVC, animated: true)
            
            handleFaceReauthSdkCallbacks(idenfyController: idenfyController, resolver: resolve)
            
        } catch let error as NSError {
            reject("error", error.domain, error)
            return
        } catch {
            reject("error", "Unexpected error. Verify that config is structured correctly.", error)
            return
        }
    }
    
    private func handleFaceReauthSdkCallbacks(idenfyController: IdenfyController, resolver resolve: @escaping RCTPromiseResolveBlock) {
        idenfyController.handleIdenfyCallbacksForFaceAuthentication(faceAuthenticationResult: {
            faceAuthenticationResult
            in
            let response = NativeResponseToReactNativeResponseMapper.mapFaceReauth(o: faceAuthenticationResult)
            resolve(response)
        })
    }
}
