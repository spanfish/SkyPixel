//
//  SPVCollectionViewCoverFlowLayout.m
//  SkyPixel
//
//  Created by xiangwei wang on 2017/06/29.
//  Copyright © 2017 Xiangwei Wang. All rights reserved.
//

#import "SPVCollectionViewCoverFlowLayout.h"

@implementation SPVCollectionViewCoverFlowLayout

-(void) prepareLayout {
    //NSAssert(self.scrollDirection == UICollectionViewScrollDirectionHorizontal, @"[SPVCollectionViewCoverFlowLayout]: Vertical scrolling isn't supported!");
    NSLog(@"prepareLayout:%@", NSStringFromCGSize(self.collectionView.bounds.size));
    NSLog(@"itemSize:%@", NSStringFromCGSize([self itemSize]));
    NSLog(@"prepareLayout");
    [super prepareLayout];
    
    //self.minimumLineSpacing = (self.collectionView.bounds.size.width - self.itemSize.width)/2;
}

-(CGSize) collectionViewContentSize {
    NSInteger rows = [self.collectionView numberOfItemsInSection:0];
    CGSize itemSize = [self itemSize];
    itemSize.width = itemSize.width * rows + (rows + 1) * self.minimumLineSpacing;
    return itemSize;
}

-(NSArray *) layoutAttributesForElementsInRect:(CGRect) rect {
    NSLog(@"layoutAttributesForElementsInRect:%@", NSStringFromCGRect(rect));
    NSInteger rows = [self.collectionView numberOfItemsInSection:0];
    if(rows == 0 || CGRectGetMaxX(rect) <= 0) {
        return nil;
    }
    
    NSArray *indices = [self indexPathsInRect:rect];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[indices count]];
    for (NSIndexPath *indexPath in indices) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        [array addObject:attr];
    }
    return array;
    
//    return [super layoutAttributesForElementsInRect:rect];
}
    
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < 0) {
        return nil;
    }
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.frame = CGRectMake(self.itemSize.width * indexPath.row + (indexPath.row + 1) * self.minimumLineSpacing,
                            (self.collectionView.bounds.size.height - self.itemSize.height)/2, self.itemSize.width, self.itemSize.height);
//    NSLog(@"cell frame row:%ld rect:%@", indexPath.row, NSStringFromCGRect(attr.frame));
//    return attr;
//    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    NSLog(@"layoutAttributesForItemAtIndexPath:%ld, frame:%@", indexPath.row, NSStringFromCGRect(attr.frame));
    return attr;
}

-(NSArray *) indexPathsInRect:(CGRect) rect {
    NSAssert([self.collectionView numberOfSections] == 1, @"[SPVCollectionViewCoverFlowLayout]: multiple sections isn't supported!");
    
    NSMutableArray *array = [NSMutableArray array];
    NSInteger minRow = rect.origin.x / (self.itemSize.width + self.minimumLineSpacing);
    NSInteger rows = [self.collectionView numberOfItemsInSection:0];
    if(minRow > 0) {
        [array addObject:[NSIndexPath indexPathForRow:minRow - 1 inSection:0]];
    }
    [array addObject:[NSIndexPath indexPathForRow:minRow inSection:0]];
    if(minRow < rows - 1) {
        [array addObject:[NSIndexPath indexPathForRow:minRow + 1 inSection:0]];
    }
    return array;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    NSInteger minRow = proposedContentOffset.x / (self.itemSize.width + self.minimumLineSpacing);
    CGFloat x = self.itemSize.width * minRow + (minRow + 1) * self.minimumLineSpacing;
    x -= (self.collectionView.bounds.size.width - self.itemSize.width)/2;
    x = MAX(0, x);
    proposedContentOffset.x = x;
    return proposedContentOffset;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    return [self targetContentOffsetForProposedContentOffset:proposedContentOffset];
}
@end
