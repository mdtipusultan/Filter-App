import UIKit
import CoreImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var collectionView: UICollectionView!
    
   
    let filters: [String] = ["CISepiaTone", "CIPhotoEffectNoir", "CIVignette", "CIPhotoEffectChrome", "CIPhotoEffectProcess","CISepiaTone", "CIPhotoEffectNoir", "CIVignette", "CIPhotoEffectChrome", "CIPhotoEffectProcess"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: view.bounds.height - 150, width: view.bounds.width, height: 100), collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "ProfileOptionCell")
        
        view.addSubview(collectionView)
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileOptionCell", for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }
        
        let filterName = filters[indexPath.item]
        cell.filterNameLabel.text = filterName
        
        // Apply filter to the cell's image
        if let selectedImage = imageView.image {
            cell.filterImageView.image = applyFilter(filterName: filterName, to: selectedImage)
        }else {
            cell.filterImageView.image = UIImage(systemName: "photo.on.rectangle") // Set the system icon as the demo icon
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.item]
        if let selectedImage = imageView.image {
            imageView.image = applyFilter(filterName: selectedFilter, to: selectedImage)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            collectionView.reloadData()
        }
    }
    
    // MARK: Helper Methods
    
    func applyFilter(filterName: String, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let filter = CIFilter(name: filterName) else {
            return nil
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}

class FilterCell: UICollectionViewCell {
    let filterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let filterNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(filterImageView)
        contentView.addSubview(filterNameLabel)
        
        NSLayoutConstraint.activate([
            filterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            filterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            filterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            filterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            filterNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            filterNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            filterNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            filterNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
