//
//  ViewController.swift
//  Jodel-iOS-Challange
//
//  Created by Ufuk Anıl Özlük on 23.04.2023.
//

import ImageSlideshow
import SkeletonView
import UIKit

class GalleryViewController: UIViewController {
    @IBOutlet var galleryCollectionView: UICollectionView!

    var currentPage: Int = 1
    var currentPhotoBatch: GalleryData.Photos?
    var totalPages: Int?
    var photos: [GalleryData.Photos.Photo] = []
    lazy var refreshControl = UIRefreshControl()
    let viewModel = PhotosViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchData(for: currentPage)
    }

    @IBAction func loadMore(_ sender: Any) {
        if currentPage < totalPages! {
            currentPage += 1
            fetchData(for: currentPage)
        }
    }

    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height){
//            let numberOfPhotos = photos.count
//            let totalPics = currentPhotoBatch!.total
//
//            if numberOfPhotos < totalPics {
//
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    self.currentPage += 1
//                    self.fetchData(for: self.currentPage)
//                }
//                print("LOOOOOLLLL\(totalPics)")
//            }
//        }
//
//    }

    func setBindings() {
        viewModel.photos.bind { [weak self] pics in
            self?.currentPhotoBatch = pics
            self?.totalPages = pics?.pages
            self?.currentPage = Int(pics!.page)!
            self?.photos += pics!.photo
        }
    }

    @objc func didPullToRefresh() {
        photos = []
        currentPage = 1
        fetchData(for: currentPage)
        addSkeleton()
    }

    func fetchData(for page: Int) {
        viewModel.getPics(page: String(page)) {
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }

    func configUI() {
        configureCollectionCellSize()

        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        addSkeleton()
        refreshControl.attributedTitle = NSAttributedString(string: "Updating")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        galleryCollectionView.addSubview(refreshControl)
    }

    func configureCollectionCellSize() {
        let width = view.frame.size.width - 30
        let layout = galleryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width - 50)
    }

    func updateUI() {
        setBindings()
        galleryCollectionView.reloadData()
        refreshControl.endRefreshing()
        removeSkeleton()
    }

    func addSkeleton() {
        galleryCollectionView.showAnimatedGradientSkeleton()
    }

    func removeSkeleton() {
        galleryCollectionView.hideSkeleton()
    }
}

extension GalleryViewController: UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        GalleryCollectionViewCell.reuseIdentifier
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseIdentifier, for: indexPath)

        if let cell = cell as? GalleryCollectionViewCell {
            let rowData = photos[indexPath.row]
            cell.set(data: rowData, indexPath: indexPath, parentVC: self)
        }
        return cell
    }
}