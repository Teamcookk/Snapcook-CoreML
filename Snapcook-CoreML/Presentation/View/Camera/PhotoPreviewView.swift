//
//  PhotoPreviewView.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 19/06/25.
//

import SwiftUI

struct PhotoPreviewView: View {
    let photo: Photo?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let photo = photo, let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("No photo available")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .navigationBarTitle("Photo Preview", displayMode: .inline)
    }
}

#Preview {
    PhotoPreviewView(photo: Photo(originalData: Data()))
}
