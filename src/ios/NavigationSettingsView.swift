//
//  NavigationSettingsView.swift
//  MyAPP4
//
//  Created by Andre Grillo on 05/05/2023.
//

import SwiftUI

struct NavigationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedNavigationType = 0
    @State private var useCurrentLocation: Bool = true {
        didSet {
            if useCurrentLocation {
                sourceLocation = ""
            }
        }
    }
    @State private var navigationType: Int = 0
    @State private var sourceLocation: String = ""
    
    let navigationTypeOptions: [(String, String)] = [
        ("car", "By Car"),
        ("person", "Walking")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                Section(header: Text("Start Location")){
                    
                    
                    
                    
                    //                Text("Source Location")
                    //                    .font(.headline)
                    //                    .frame(maxWidth: .infinity, alignment: .leading)
                    //                    .padding(.leading, 20)
                    
                    Toggle(isOn: $useCurrentLocation) {
                        Text("Use Current Location")
                            .foregroundColor(useCurrentLocation ? .primary : .gray)
                            .font(.system(size: 15))
                            .opacity(0.7)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    
                    
//                    if !useCurrentLocation {
                        Button(action: {
                            // Select Start Location action
                        }) {
                            HStack {
                                Image(systemName: "restart.circle.fill")
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                Text("Select Start Location")
                                    .font(.system(size: 15))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(useCurrentLocation ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .disabled(useCurrentLocation)
                        
//                        TextField("Enter Source Location", text: $sourceLocation)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding()
//                            .disabled(useCurrentLocation)
//                            .opacity(useCurrentLocation ? 0.5 : 1.0)
//                            .padding(.horizontal)
                        
//                    } else {
//                        //Spacer().frame(height: 8)
//                    }
                }
            
                
            
                    Section(header: Text("Destination")){
                        
                        Button(action: {
                            // Show route action
                        }) {
                            HStack {
                                Image(systemName: "pin.fill")
                                    .resizable()
                                    .frame(width: 11, height: 15)
                                Text("Select Destination")
                                    .font(.system(size: 16))
                            }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
//                        Text("Destination")
//                            .font(.headline)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.top, 10)
                        
//                        TextField("Enter Destination Location", text: .constant(""))
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.leading, 20)
//                            .padding(.trailing, 20)
                        
                        
                    }
                    
                
                    Section(header: Text("Navigation")){
//                        Text("Navigation Type")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 20)
//                            .padding(.top)
//
                        Picker("", selection: $selectedNavigationType) {
                            HStack {
                                Image(systemName: "car")
                                //Text("By Car")
                            }
                            .tag(0)
                            
                            HStack {
                                Image(systemName: "figure.walk")
                                //Text("Walking")
                            }
                            .tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        Button(action: {
                            // Show route action
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Show Route")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        
                        //                Button(action: {
                        //                    // Show route action
                        //                }) {
                        //                    Text("Show Route")
                        //                        .frame(maxWidth: .infinity)
                        //                        .padding()
                        //                        .background(Color.blue)
                        //                        .foregroundColor(.white)
                        //                        .cornerRadius(8)
                        //                }
                        //                .padding(.horizontal)
                        
                        Button(action: {
                            // Simulate route action
                        }) {
                            HStack {
                                Image(systemName: "car.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Simulate Route")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // Start navigation action
                        }) {
                            HStack {
                                Image(systemName: "arrow.turn.up.right")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Start Navigation")
                                    .font(.system(size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                    }
                    
                }
            }
            .navigationBarTitle("Navigation Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
            })
        }
        .background(Color.white.opacity(0.8).edgesIgnoringSafeArea(.all))
    }
}

struct NavigationTypeView: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
    }
}
