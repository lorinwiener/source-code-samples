'use strict';

import _ from 'lodash';
import * as dimension from './ScreenDimensions';

/**
 * Always center navigation and animation travel distance for Horizontal and Vertical Carousels
 *
 * @param widthHeight: with or height of an item depends on the orientation
 * @param itemMargin
 * @param focus: highlighted item index
 * @param orientation: landscape/portrait (X/Y)
 * @param extraWH: extra width of height outside the carousel
 * @returns {number}
 */

export function carouselCenterScroll(widthHeight, itemMargin, focus, orientation, extraWH) {

    if (widthHeight !== undefined && itemMargin !== undefined && focus !== undefined && orientation !== undefined) {
        var centerXY = (orientation === "X") ? dimension.getScreenCenterXPerDom(widthHeight, extraWH) :
            dimension.getScreenCenterYPerDom(widthHeight, extraWH) ;

        var activeItemX = (focus * (widthHeight + itemMargin)) + itemMargin;
        var movement = (activeItemX > centerXY) ? centerXY - activeItemX : 0;

        return movement;
    }
    return 0;
}

/**
 * Calculate navigation and animation travel distance for Horizontal and Vertical Carousels
 *
 * @param widthHeight: with or height of an item depends on the orientation
 * @param itemMargin
 * @param focus: highlighted item index
 * @param size: carousel item size
 * @param orientation: landscape/portrait (X/Y)
 * @param extraWH: extra width of height outside the carousel
 * @returns {number}
 */

export function carouselScroll(widthHeight, itemMargin, focus, size, orientation, extraWH) {

    if (widthHeight !== undefined && itemMargin !== undefined && focus !== undefined && size !== undefined && orientation !== undefined) {
        var centerXY = (orientation === "X") ? dimension.getScreenCenterXPerDom(widthHeight, extraWH) :
            dimension.getScreenCenterYPerDom(widthHeight, extraWH) ;

        var endCount = _.ceil(centerXY / (widthHeight + itemMargin));
        var lastStaticCount = parseInt(size) - endCount;
        var overflowWidth = endCount * (widthHeight + itemMargin) - centerXY - widthHeight;

        var scrollFocus = (focus > lastStaticCount) ? lastStaticCount : focus;
        var activeItemX = (scrollFocus * (widthHeight + itemMargin)) + itemMargin;
        var movement = (activeItemX > centerXY) ? centerXY - activeItemX : 0;

        if (focus >= lastStaticCount) {
            movement -= overflowWidth;
        }

        return movement;
    }
    return 0;
}

/**
 * Calculate navigation and animation travel distance for carousels with items of variable widths
 * Once reached the center, always center the active poster
 *
 * @param numOfItems
 * @param margin
 * @param orientation
 * @param focus
 * @param singleWidth
 * @param extraWH
 * @param actionCol
 * @param widths
 * @returns {{dist: number, pos: string}}
 */
export function carouselCenterVariableScroll(numOfItems, margin, orientation, focus, singleWidth, extraWH, actionCol, widths) {
    var movement = 0;
    var mmt = {"dist": 0, "pos": "middle"};

    if (numOfItems !== undefined && margin !== undefined && orientation !== undefined && focus !== undefined && singleWidth !== undefined && extraWH !== undefined) {
        var activeCol = widths[focus];
        var centerXY = (orientation === 'X') ? dimension.getScreenCenterXPerDom(activeCol * singleWidth, extraWH)
            : dimension.getScreenCenterYPerDom(activeCol * singleWidth, extraWH);

        if (actionCol !== undefined) {
            movement = actionCol;
        }

        for (let index = 0; index < focus; index++) {
            movement += ((widths[index] * singleWidth) + margin);
        }

        mmt.dist = (movement > centerXY) ? (centerXY - movement) : 0;
        if (movement < centerXY) {
            mmt.pos = "right";
        }

        return mmt;
    }
    return mmt;
}