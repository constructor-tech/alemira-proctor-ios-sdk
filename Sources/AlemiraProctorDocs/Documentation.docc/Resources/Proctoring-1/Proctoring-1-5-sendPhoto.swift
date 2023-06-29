import AlemiraProctor

guard let image = info[.originalImage] as? UIImage,
      let imageData = image.jpegData(compressionQuality: 0.7)
else {
    return
}
let type: PhotoType
...
AlemiraLib.instance.session?.uploadPhoto(imageData: imageData, type: type) { [weak self] result in
    switch result {
    case .success(_): ...
    default: break
    }
}
