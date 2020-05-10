//
//  SourcesVC.swift
//  News API
//
//  Created by Cao Mai on 4/30/20.
//  Copyright © 2020 Make School. All rights reserved.
//

import UIKit

class SourcesVC: UIViewController {
    
    @IBOutlet weak var sourcesCollectionView: UICollectionView!
    
    var sources : [NewsSource] = [] {
        didSet {
            sourcesCollectionView.reloadData()
        }
    }
    
    let uiColors = [#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)]
    let networkManager = NetworkManager()
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourcesCollectionView.dataSource = self
        sourcesCollectionView.delegate = self
        sourcesCollectionView.register(UINib(nibName: "CategoryCell", bundle: .main), forCellWithReuseIdentifier: "categoryCell")
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Top News by Source"
        self.navigationController!.tabBarItem.title = "Sources"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .done, target: self, action: #selector(showOptions(controller:)))
        
        fetchSources()
    }
    
    @objc func showOptions(controller: UIViewController) {
        
        let alert = UIAlertController(title: "Sort By", message: "Choose how news sources are ordered", preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "Category", style: .default, handler: { (_) in
            self.sort(sources: &self.sources)
        }))
        
        alert.addAction(UIAlertAction(title: "Default", style: .default, handler: { (_) in
            self.fetchSources()
        }))

        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func fetchSources() {
        networkManager.getSources() { result in
            switch result {
            case let .success(source):
                self.sources = source!.sources
                
            case let .failure(gotError):
                print(gotError)
            }
        }
        //        print(sources)
    }
    
    func sort(sources: inout [NewsSource]) {
        sources.sort(by: {
            var isSorted = false // In order to upwrap the optional
            if let first = $0.category, let second = $1.category {
                isSorted = first < second
            }
            return isSorted
        })
    }
    
}


extension SourcesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        //        cell.backgroundColor = uiColors[indexPath.row]
        let sourceCategory = sources[indexPath.row].category
        
        switch sourceCategory?.capitalized {
        case K.general:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.generalColor.rawValue
        case K.business:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.businessColor.rawValue
        case K.science:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.scienceColor.rawValue
        case K.technology:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.techColor.rawValue
        case K.health:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.healthColor.rawValue
        case K.entertainment:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.entertainColor.rawValue
        case K.sports:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.sportsColor.rawValue
        default:
            cell.newSourceCategoryColor.backgroundColor = ProjectColor.generalColor.rawValue
        }
        cell.backgroundColor = #colorLiteral(red: 0.9561000466, green: 0.941519022, blue: 0.9314298034, alpha: 1)
        cell.categoryLabelName.text = sources[indexPath.row].name
        cell.categoryLabelName.textColor = #colorLiteral(red: 0.05834504962, green: 0.05800623447, blue: 0.05861062557, alpha: 1)
        cell.newsSourceCategoryLabel.text = sourceCategory?.capitalized
        
        return cell
    }
}

extension SourcesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let newVS = HeadlinesVC()
        
        //        self.present(newVS, animated: true, completion: nil)
        
        //        networkManager.getArticles(passedInCategory: "health"){ result in
        //            switch result {
        //            case let .success(gotArticles):
        //                self.articles = gotArticles
        //            case let .failure(gotError):
        //                print(gotError)
        //            }
        guard let selectedSource = sources[indexPath.row].id else {
            return
        }
        
        networkManager.getArticlesFromSource(from: selectedSource) { result in
            switch result {
            case let .success(gotArticles):
                //                print(gotArticles)
                let sampleStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let headLineVC  = sampleStoryBoard.instantiateViewController(withIdentifier: "headlinesVC") as! HeadlinesVC
                headLineVC.headlines = gotArticles!
                headLineVC.category = self.sources[indexPath.row].name
                self.navigationController?.pushViewController(headLineVC, animated: true)
                
            case let .failure(gotError):
                print(gotError)
            }
        }
        //        let newsVC = DetailNewsStoryVC()
        //        self.present(newsVC, animated: true, completion: nil)
        
    }
    
}

extension SourcesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 12, bottom: 10, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}


