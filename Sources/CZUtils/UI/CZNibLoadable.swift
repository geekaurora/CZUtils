//
//  CZNibLoadable.swift
//
//  Created by Cheng Zhang on 4/19/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/// A view that has an accompanying xib file by the same name and make use of `loadFromNib`
public protocol CZNibLoadable: class {
    /// xib filename: same as View className by default. If you need to customize xibName, just override `var xibName: String` in your class
    var xibName: String? {get}
    /// Content view loaded from nib file
    var nibContentView: UIView! {get set}
}

// MARK: - CZNibLoadableView
/// - Brief: Base class for view which is loaded from xib file.
///
/// - Usage:
///   1. Create xib file with the same name as SubViewClass
///   2. Set SubViewClass as xib file's owner
///   3. xibName: same as View className by default. If you need to customize xibName, just override `var xibName: String` in your class
///
/// - Note:
///   1. nibContentView, the first top level view in nib file, is added and overlapped on SubViewClass with zero inset
///   2. override setupViews() for customized initialization if needed, required to invoke super.setupViews()
@objc open class CZNibLoadableView: UIView, CZNibLoadable {
    open var xibName: String? { return nil }
    open var nibContentView: UIView!
    
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Setup
    open func setupViews() {
        _loadAndOverlay(on: self)
    }
}

// MARK: - CZNibLoadableTableViewCell
@objc open class CZNibLoadableTableViewCell: UITableViewCell, CZNibLoadable {
    open var xibName: String? { return nil }
    open var nibContentView: UIView!
    private var nibIsLoaded: Bool = false
    
    // MARK: - Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Setup
    open func setupViews() {
        guard !nibIsLoaded else {return}
        nibIsLoaded = true
        _loadAndOverlay(on: self)
    }
}

// MARK: - CZNibLoadableCollectionViewCell
@objc open class CZNibLoadableCollectionViewCell: UICollectionViewCell, CZNibLoadable {
    open var nibContentView: UIView!
    open var xibName: String? { return nil }
    private var nibIsLoaded: Bool = false
    
    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Setup
    open func setupViews() {
        guard !nibIsLoaded else {return}
        nibIsLoaded = true
        // should be self, contentView doesn't overlap?
        _loadAndOverlay(on: self)
    }
}

// MARK: - Private Methods

/// extension of UIView conforms to CZNibLoadable
private extension CZNibLoadable where Self: UIView {
    /// Load form nib file and overlay the contentView on superView
    func _loadAndOverlay(on superView: UIView) {
        nibContentView = loadAndOverlay(on: superView, xibName: xibName)
    }
}
