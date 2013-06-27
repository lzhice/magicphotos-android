import bb.cascades 1.0
import bb.system 1.0
import FilePicker 1.0
import CustomTimer 1.0
import ImageEditor 1.0

Page {
    id: recolorPage

    function openImage(image_file) {
        activityIndicator.visible = true;
        activityIndicator.start();

        recolorEditor.openImage(image_file);
    }

    paneProperties: NavigationPaneProperties {
        backButton: ActionItem {
            onTriggered: {
                navigationPane.pop();
            }
        }
    }

    actions: [
        ActionItem {
            id:                  undoActionItem
            title:               qsTr("Undo")
            imageSource:         "images/undo.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled:             false

            onTriggered: {
                recolorEditor.undo();
            }
        },
        ActionItem {
            id:                  saveActionItem
            title:               qsTr("Save")
            imageSource:         "images/save.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled:             false

            onTriggered: {
                if (TrialManager.trialMode) {
                    trialModeDialog.show();
                } else {
                    saveFilePicker.open();
                }
            }
            
            attachedObjects: [
                FilePicker {
                    id:             saveFilePicker
                    type:           FileType.Picture
                    mode:           FilePickerMode.Saver
                    allowOverwrite: true
                    title:          qsTr("Save Image")
                    
                    onFileSelected: {
                        recolorEditor.saveImage(selectedFiles[0]);
                    } 
                },
                SystemDialog {
                    id:    trialModeDialog
                    title: qsTr("Info")
                    body:  qsTr("The save function is available in the full version only. Do you want to purchase full version now?")
                    
                    onFinished: {
                        if (result === SystemUiResult.ConfirmButtonSelection) {
                            appWorldInvocation.trigger("bb.action.OPEN");
                        }
                    }
                },
                SystemDialog {
                    id:                  requestFeedbackDialog
                    title:               qsTr("Info")
                    body:                qsTr("If you like this app, please take a moment to provide a feedback and rate it. Do you want to provide a feedback?")
                    confirmButton.label: qsTr("Yes")
                    cancelButton.label:  qsTr("Later")
                    customButton.label:  qsTr("Never")

                    onFinished: {
                        if (result === SystemUiResult.ConfirmButtonSelection) {
                            appWorldInvocation.trigger("bb.action.OPEN");

                            AppSettings.requestFeedback = false;
                        } else if (result === SystemUiResult.CancelButtonSelection) {
                            AppSettings.lastRequestLaunchNumber = AppSettings.launchNumber;
                        } else if (result === SystemUiResult.CustomButtonSelection) {
                            AppSettings.requestFeedback = false;
                        }
                    }
                },
                CustomTimer {
                    id:       requestFeedbackTimer
                    interval: 1000

                    onTimeout: {
                        if (AppSettings.requestFeedback && AppSettings.launchNumber > 1 && AppSettings.lastRequestLaunchNumber !== AppSettings.launchNumber) {
                            requestFeedbackDialog.show();
                        }
                    }
                },
                Invocation {
                    id: appWorldInvocation

                    query: InvokeQuery {
                        mimeType: "application/x-bb-appworld"
                        uri:      "appworld://content/20356189"
                    }
                }
            ]
        },
        ActionItem {
            id:                  helpActionItem
            title:               qsTr("Help")
            imageSource:         "images/help.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                navigationPane.push(helpPageDefinition.createObject());
            }

            attachedObjects: [
                ComponentDefinition {
                    id:     helpPageDefinition
                    source: "HelpPage.qml"
                }
            ]
        }
    ]
    
    Container {
        id:         recolorPageContainer
        background: Color.Black

        layout: StackLayout {
        }

        SegmentedControl {
            id:                  modeSegmentedControl
            horizontalAlignment: HorizontalAlignment.Center
            
            onSelectedValueChanged: {
                if (selectedValue === RecolorEditor.ModeScroll) {
                    imageScrollView.touchPropagationMode = TouchPropagationMode.Full;
                } else {
                    imageScrollView.touchPropagationMode = TouchPropagationMode.PassThrough;
                }
                if (selectedValue === RecolorEditor.ModeHueSelection) {
                    hueSelectionContainer.visible = true;
                } else {
                    hueSelectionContainer.visible = false;
                }

                recolorEditor.mode = selectedValue;
            }

            layoutProperties: StackLayoutProperties {
                spaceQuota: -1
            }

            Option {
                id:          scrollModeOption
                value:       RecolorEditor.ModeScroll
                imageSource: "images/mode_scroll.png"
            }

            Option {
                id:          originalModeOption
                value:       RecolorEditor.ModeOriginal
                imageSource: "images/mode_original.png"
                enabled:     false
            }

            Option {
                id:          effectedModeOption
                value:       RecolorEditor.ModeEffected
                imageSource: "images/mode_effected.png"
                enabled:     false
            }

            Option {
                id:          hueSelectionModeOption
                value:       RecolorEditor.ModeHueSelection
                imageSource: "images/mode_hue_selection.png"
                enabled:     false
            }
        }

        Container {
            id:                  imageContainer
            preferredWidth:      65535
            horizontalAlignment: HorizontalAlignment.Center 
            background:          Color.Transparent

            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }

            layout: DockLayout {
            }

            function showHelper(touch_x, touch_y) {
                if (modeSegmentedControl.selectedValue !== RecolorEditor.ModeScroll && modeSegmentedControl.selectedValue !== RecolorEditor.ModeHueSelection) {
                    helperImageView.visible = true;

                    var local_x = imageScrollViewLayoutUpdateHandler.layoutFrame.x + touch_x * imageScrollView.contentScale - imageScrollView.viewableArea.x;
                    var local_y = imageScrollViewLayoutUpdateHandler.layoutFrame.y + touch_y * imageScrollView.contentScale - imageScrollView.viewableArea.y;
    
                    if (local_y < helperImageViewLayoutUpdateHandler.layoutFrame.height * 2) {
                        if (local_x < helperImageViewLayoutUpdateHandler.layoutFrame.width * 2) {
                            helperImageView.horizontalAlignment = HorizontalAlignment.Right;
                        } else if (local_x > imageContainerLayoutUpdateHandler.layoutFrame.width - helperImageViewLayoutUpdateHandler.layoutFrame.width * 2) {
                            helperImageView.horizontalAlignment = HorizontalAlignment.Left;
                        }
                    }
                } else {
                    helperImageView.visible = false;
                }
            }

            ScrollView {
                id:                   imageScrollView
                horizontalAlignment:  HorizontalAlignment.Center
                verticalAlignment:    VerticalAlignment.Center
                touchPropagationMode: TouchPropagationMode.Full
                
                scrollViewProperties {
                    scrollMode:         ScrollMode.Both
                    pinchToZoomEnabled: true
                    minContentScale:    1.0
                    maxContentScale:    4.0
                }            
                
                ImageView {
                    id:            imageView
                    scalingMethod: ScalingMethod.AspectFit 
                    
                    onTouch: {
                        if (event.touchType === TouchType.Down) {
                            imageContainer.showHelper(event.localX, event.localY);

                            recolorEditor.changeImageAt(true, event.localX, event.localY, imageScrollView.contentScale);
                        } else if (event.touchType === TouchType.Move) {
                            imageContainer.showHelper(event.localX, event.localY);

                            recolorEditor.changeImageAt(false, event.localX, event.localY, imageScrollView.contentScale);
                        } else {
                            helperImageView.visible = false;
                        }
                    }

                    attachedObjects: [
                        RecolorEditor {
                            id:   recolorEditor
                            mode: RecolorEditor.ModeScroll
                            hue:  180 

                            onImageOpened: {
                                activityIndicator.stop();
                                activityIndicator.visible = false;
                                
                                saveActionItem.enabled = true;
                                
                                modeSegmentedControl.selectedOption = scrollModeOption;
                                
                                originalModeOption.enabled     = true;
                                effectedModeOption.enabled     = true;
                                hueSelectionModeOption.enabled = true;
                                
                                imageScrollView.resetViewableArea(ScrollAnimation.Default);
                            }

                            onImageOpenFailed: {
                                activityIndicator.stop();
                                activityIndicator.visible = false;
                                
                                saveActionItem.enabled = false;
                                
                                modeSegmentedControl.selectedOption = scrollModeOption;
                                
                                originalModeOption.enabled     = false;
                                effectedModeOption.enabled     = false;
                                hueSelectionModeOption.enabled = false;
                                
                                imageScrollView.resetViewableArea(ScrollAnimation.Default);

                                imageOpenFailedToast.show();
                            }
                            
                            onImageSaved: {
                                imageSavedToast.show();

                                requestFeedbackTimer.start();
                            }
                            
                            onImageSaveFailed: {
                                imageSaveFailedToast.show();
                            }
                            
                            onUndoAvailabilityChanged: {
                                if (available) {
                                    undoActionItem.enabled = true;
                                } else {
                                    undoActionItem.enabled = false;
                                }
                            }
                            
                            onNeedImageRepaint: {
                                imageView.image = image;                            
                            }
                            
                            onNeedHelperRepaint: {
                                helperImageView.image = image;
                            }
                        },
                        SystemToast {
                            id:   imageOpenFailedToast
                            body: qsTr("Could not open image")
                        },
                        SystemToast {
                            id:   imageSavedToast
                            body: qsTr("Image saved successfully")
                        },
                        SystemToast {
                            id:   imageSaveFailedToast
                            body: qsTr("Could not save image")
                        }
                    ]
                }
                
                attachedObjects: [
                    LayoutUpdateHandler {
                        id: imageScrollViewLayoutUpdateHandler
                    }
                ]
            }
            
            Container {
                id:                  hueSelectionContainer
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment:   VerticalAlignment.Center
                visible:             false
                
                onVisibleChanged: {
                    if (visible) {
                        hueSliderImageView.layoutProperties.positionY = Math.max(0, Math.min(hueBarImageView.preferredHeight - hueSliderImageView.preferredHeight, recolorEditor.hue));
                    }
                }
                
                layout: AbsoluteLayout {
                }

                ImageView {
                    id:              hueBarImageView
                    preferredWidth:  128
                    preferredHeight: 360
                    minWidth:        preferredWidth
                    minHeight:       preferredHeight
                    maxWidth:        preferredWidth
                    maxHeight:       preferredHeight
                    imageSource:     "images/hue_bar.png"
                    
                    onTouch: {
                        if (event.touchType === TouchType.Down || event.touchType === TouchType.Move) {
                            hueSliderImageView.layoutProperties.positionY = Math.max(0, Math.min(hueBarImageView.preferredHeight - hueSliderImageView.preferredHeight, event.localY));

                            recolorEditor.hue = Math.max(0, Math.min(360, event.localY));
                        }
                    }  

                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0
                        positionY: 0
                    }
                }
                
                ImageView {
                    id:                   hueSliderImageView
                    preferredWidth:       128
                    preferredHeight:      24
                    minWidth:             preferredWidth
                    minHeight:            preferredHeight
                    maxWidth:             preferredWidth
                    maxHeight:            preferredHeight
                    imageSource:          "images/hue_slider.png"
                    touchPropagationMode: TouchPropagationMode.PassThrough
                    overlapTouchPolicy:   OverlapTouchPolicy.Allow

                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0
                        positionY: 0
                    }  
                }
            }

            ImageView {
                id:                  helperImageView
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment:   VerticalAlignment.Top
                visible:             false
                
                attachedObjects: [
                    LayoutUpdateHandler {
                        id: helperImageViewLayoutUpdateHandler
                    }
                ]
            } 

            ActivityIndicator {
                id:                  activityIndicator
                preferredWidth:      256
                preferredHeight:     256
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment:   VerticalAlignment.Center
                visible:             false
            }

            attachedObjects: [
                LayoutUpdateHandler {
                    id: imageContainerLayoutUpdateHandler
                }
            ]
        }
    }
}
