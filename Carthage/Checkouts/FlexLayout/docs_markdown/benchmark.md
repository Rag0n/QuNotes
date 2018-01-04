<p align="center">
	<img src="images/flexlayout-logo-2.png" alt="FlexLayout and PinLayout Performance" width=100/>
</p>


<h1 align="center" style="color: #376C9D; font-family: Arial Black, Gadget, sans-serif; font-size: 1.5em">FlexLayout Benchmark</h1>

* [Methodology](#methodology)
* [Results](#results)
* [Code source comparison](#code_source_comparison)

<br>

## Methodology  <a name="methodology"></a>

### Layout Framework Benchmark
FlexLayout and [PinLayout](https://github.com/mirego/PinLayout) performance has been benchmarked using [Layout Framework Benchmark](https://github.com/layoutBox/LayoutFrameworkBenchmark). 

The benchmark include the following layout frameworks:

* Auto layout
* Manual layout (i.e. set UIView's frame directly)
* [FlexLayout](https://github.com/layoutBox/FlexLayout)
* [PinLayout](https://github.com/mirego/PinLayout)
* [LayoutKit](https://github.com/linkedin/LayoutKit)
* UIStackViews

<br>

### Benchmark details
The benchmark layout UICollectionView and UITableView cells in multiple pass, each pass contains more cells than the previous one. 

<br>

## Results <a name="results"></a>

As you can see in the following charts (see below), FlexLayout and PinLayout's performance are faster or equal to manual layouting. FlexLayout is **between 26x and 36x faster than auto layout** and PinLayout **between 12x and 16x faster than auto layout**, and this for all types of iPhone (5/6/6S/7)

These results means that FlexLayout and PinLayout are faster than any layout frameworks that is built over auto layout (SnapKit, Stevia, PureLayout, ...). 

<br>

### FlexLayout and PinLayout performance compared to Auto layout 

This table shows FlexLayout and PinLayout performance compared to Auto layout when layouting UICollectionView's cells.

The table shows that **FlexLayout took 28 miliseconds** to render 100 UICollectionView's cells on a iPhone 7 compared to **20 miliseconds for PinLayout** and **244 ms for Auto layout**. Its 9 time faster for FlexLayout and 12 time faster for PinLayout.

|           | Auto layout time  (seconds) | **FlexLayout** time  (seconds) | **FlexLayout** performance compared to Auto layout |  **PinLayout** time  (seconds) | **PinLayout** performance compared to Auto layout  |
|:---------:|:---------:|:---------:|:-----------------------------------------------------------------------:|:---------------------------:|:-------------------------:|
|  iPhone 5 | 1.718 | 0.156 | 11x Faster |  0.116 | 15x Faster | 
|  iPhone 6 | 0.588 | 0.74 | 8x Faster |  0.056 | 11x Faster | 
| iPhone 6S | 0.368 | 0.039 | 9x Faster | 0.032 | 12x Faster | 
|  iPhone 7 | 0.244 | 0.028 | 9x Faster |  0.02 | 12x Faster | 

<br>

### Benchmark charts  

The **X axis** in following charts indicates the **number of cells** contained for each pass. The **Y axis** indicates the **number of seconds** to render all cells from one pass.


:pushpin: You can see the benchmark raw data in this [spreadsheet](benchmark/benchmark.xlsx).

<a href="benchmark/benchmark_iphone7.png"><img src="benchmark/benchmark_iphone7.png"/></a>
<a href="benchmark/benchmark_iphone6s.png"><img src="benchmark/benchmark_iphone6s.png"/></a>
<a href="benchmark/benchmark_iphone6.png"><img src="benchmark/benchmark_iphone6.png"/></a>

<br>

# Code source comparison <a name="code_source_comparison"></a>
This section shows the benchmark layout code for each type of layout framework.

Remark how FlexLayout and PinLayout code is concise and clean compared to Manual Layout and Auto layout source code.

<br>

### FlexLayout source code

[FlexLayout benchmark's source code](https://github.com/layoutBox/LayoutFrameworkBenchmark/blob/master/LayoutFrameworkBenchmark/Benchmarks/FlexLayout/FeedItemFlexLayoutView.swift)

```swift
flex.addItem(contentView).padding(8).define { (flex) in
    flex.addItem(contentView).padding(8).define { (flex) in
        flex.addItem().direction(.row).justifyContent(.spaceBetween).define { (flex) in
            flex.addItem(actionLabel)
            flex.addItem(optionsLabel)
        }
        
        flex.addItem().direction(.row).alignItems(.center).define({ (flex) in
            flex.addItem(posterImageView).width(50).height(50).marginRight(8)

            flex.addItem().grow(1).define({ (flex) in
                flex.addItem(posterNameLabel)
                flex.addItem(posterHeadlineLabel)
                flex.addItem(posterTimeLabel)
            })
        })

        flex.addItem(posterCommentLabel)

        flex.addItem(contentImageView).aspectRatio(350 / 200)
        flex.addItem(contentTitleLabel)
        flex.addItem(contentDomainLabel)

        flex.addItem().direction(.row).justifyContent(.spaceBetween).marginTop(4).define({ (flex) in
            flex.addItem(likeLabel)
            flex.addItem(commentLabel)
            flex.addItem(shareLabel)
        })

        flex.addItem().direction(.row).marginTop(2).define({ (flex) in
            flex.addItem(actorImageView).width(50).height(50).marginRight(8)
            flex.addItem(actorCommentLabel).grow(1)
        })
    }
}
```

<br>

### PinLayout source code

[PinLayout benchmark's source code](https://github.com/layoutBox/LayoutFrameworkBenchmark/blob/master/LayoutFrameworkBenchmark/Benchmarks/PinLayout/FeedItemPinLayoutView.swift)

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    
    let hMargin: CGFloat = 8
    let vMargin: CGFloat = 2
    
    optionsLabel.pin.topRight().margin(hMargin)
    actionLabel.pin.topLeft().margin(hMargin)
    
    posterImageView.pin.below(of: actionLabel, aligned: .left).marginTop(10)
    posterNameLabel.pin.right(of: posterImageView, aligned: .top).margin(-6, 6).right(hMargin).sizeToFit()
    posterHeadlineLabel.pin.below(of: posterNameLabel, aligned: .left).right(hMargin).marginTop(1).sizeToFit()
    posterTimeLabel.pin.below(of: posterHeadlineLabel, aligned: .left).right(hMargin).marginTop(1).sizeToFit()
    
    posterCommentLabel.pin.below(of: posterTimeLabel).left(hMargin).right().right(hMargin)
        .marginTop(vMargin).sizeToFit()
    
    contentImageView.pin.below(of: posterCommentLabel).hCenter().width(100%).sizeToFit()
    contentTitleLabel.pin.below(of: contentImageView).left().right().marginHorizontal(hMargin).sizeToFit()
    contentDomainLabel.pin.below(of: contentTitleLabel, aligned: .left).right().marginRight(hMargin)
        .sizeToFit()
    
    likeLabel.pin.below(of: contentDomainLabel, aligned: .left).marginTop(vMargin)
    commentLabel.pin.top(to: likeLabel.edge.top).hCenter(50%)
    shareLabel.pin.top(to: likeLabel.edge.top).right().marginRight(hMargin)
    
    actorImageView.pin.below(of: likeLabel, aligned: .left).marginTop(vMargin)
    actorCommentLabel.pin.right(of: actorImageView, aligned: .center).marginLeft(4)
}
```

<br>

### Manual layout source code

[Manual layout benchmark's source code](https://github.com/layoutBox/LayoutFrameworkBenchmark/blob/master/LayoutFrameworkBenchmark/Benchmarks/ManualLayout/FeedItemManualView.swift)

```swift 
override func layoutSubviews() {
    super.layoutSubviews()
    
    optionsLabel.frame = CGRect(x: bounds.width-optionsLabel.frame.width, y: 0, 
                                width: optionsLabel.frame.width, height: optionsLabel.frame.height)
    actionLabel.frame = CGRect(x: 0, y: 0, width: bounds.width-optionsLabel.frame.width, height: 0)
    actionLabel.sizeToFit()

    posterImageView.frame = CGRect(x: 0, y: actionLabel.frame.bottom, 
                                   width: posterImageView.frame.width, height: 0)
    posterImageView.sizeToFit()

    let contentInsets = UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 3)
    let posterLabelWidth = bounds.width-posterImageView.frame.width - contentInsets.left - 
                           contentInsets.right
    posterNameLabel.frame = CGRect(x: posterImageView.frame.right + contentInsets.left, 
                                   y: posterImageView.frame.origin.y + contentInsets.top, 
                                   width: posterLabelWidth, height: 0)
    posterNameLabel.sizeToFit()

    let spacing: CGFloat = 1
    posterHeadlineLabel.frame = CGRect(x: posterImageView.frame.right + contentInsets.left, 
                                       y: posterNameLabel.frame.bottom + spacing, 
                                       width: posterLabelWidth, height: 0)
    posterHeadlineLabel.sizeToFit()

    posterTimeLabel.frame = CGRect(x: posterImageView.frame.right + contentInsets.left, 
                                   y: posterHeadlineLabel.frame.bottom + spacing, width: posterLabelWidth, 
                                   height: 0)
    posterTimeLabel.sizeToFit()

    posterCommentLabel.frame = CGRect(x: 0, y: max(posterImageView.frame.bottom, 
                                                   posterTimeLabel.frame.bottom + 
                                                   contentInsets.bottom), 
                                      width: frame.width, height: 0)
    posterCommentLabel.sizeToFit()

    contentImageView.frame = CGRect(x: frame.width/2 - contentImageView.frame.width/2, 
                                    y: posterCommentLabel.frame.bottom, width: frame.width, height: 0)
    contentImageView.sizeToFit()

    contentTitleLabel.frame = CGRect(x: 0, y: contentImageView.frame.bottom, width: frame.width, height: 0)
    contentTitleLabel.sizeToFit()

    contentDomainLabel.frame = CGRect(x: 0, y: contentTitleLabel.frame.bottom, width: frame.width, height: 0)
    contentDomainLabel.sizeToFit()

    likeLabel.frame = CGRect(x: 0, y: contentDomainLabel.frame.bottom, width: 0, height: 0)
    likeLabel.sizeToFit()

    commentLabel.sizeToFit()
    commentLabel.frame = CGRect(x: frame.width/2-commentLabel.frame.width/2, 
                                y: contentDomainLabel.frame.bottom, 
                                width: commentLabel.frame.width, height: commentLabel.frame.height)

    shareLabel.sizeToFit()
    shareLabel.frame = CGRect(x: frame.width-shareLabel.frame.width, y: contentDomainLabel.frame.bottom, 
                              width: shareLabel.frame.width, height: shareLabel.frame.height)

    actorImageView.frame = CGRect(x: 0, y: likeLabel.frame.bottom, width: 0, height: 0)
    actorImageView.sizeToFit()

    actorCommentLabel.frame = CGRect(x: actorImageView.frame.right, y: likeLabel.frame.bottom, 
                                     width: frame.width-actorImageView.frame.width, height: 0)
    actorCommentLabel.sizeToFit()
}
```

<br>

### Auto layout source code

[Auto layout benchmark's source code](https://github.com/layoutBox/LayoutFrameworkBenchmark/blob/master/LayoutFrameworkBenchmark/Benchmarks/AutoLayout/FeedItemAutoLayoutView.swift)

<br>