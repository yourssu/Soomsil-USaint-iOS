//
//  BaseViewController.swift
//  SaintKit
//
//  Created by Gyuni on 2021/12/18.
//

import RxSwift
import UIKit
import YDS

class BaseViewController: UIViewController {

    var disposeBag = DisposeBag()
    var viewModel: BaseViewBindable?

    func bind(viewModel: BaseViewBindable) {
        self.viewModel = viewModel

        rx.viewDidLoad
            .map { _ in () }
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)

        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .map { _ in () }
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)

        rx.viewWillDisappear
            .map { _ in () }
            .bind(to: viewModel.viewWillDisappear)
            .disposed(by: disposeBag)

        rx.viewDidDisappear
            .map { _ in () }
            .bind(to: viewModel.viewDidDisappear)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        setViewProperties()
        setViewHierarchies()
        setViewLayouts()
    }

    func setViewProperties() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        #if APPCLIP
        view.backgroundColor = YDSColor.bgNormal
        #else
        view.backgroundColor = YDSColor.bgNormal
        #endif
    }

    func setViewHierarchies() { }

    func setViewLayouts() { }

}
