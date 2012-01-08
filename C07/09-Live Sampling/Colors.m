//
//  Colors.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/18/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "Colors.h"

void rgbtohsb(CGFloat r, CGFloat g, CGFloat b, CGFloat *pH, CGFloat *pS, CGFloat *pV)
{
	CGFloat h,s,v;
	
	// 從Foley與Van Dam那抄來的
	CGFloat max = MAX(r, MAX(g, b));
	CGFloat min = MIN(r, MIN(g, b));
	
	// 明亮度
	v = max;
	
	// 飽和度
	s = (max != 0.0f) ? ((max - min) / max) : 0.0f;
	
	if (s == 0.0f) {
		// 沒有飽和度，所以色調未定義
		h = 0.0f;
	} else {
		// 決定色調
		CGFloat rc = (max - r) / (max - min);		// 與紅色值的距離
		CGFloat gc = (max - g) / (max - min);		// 與綠色值的距離
		CGFloat bc = (max - b) / (max - min);		// 與藍色值的距離
		
		if (r == max) h = bc - gc;					// 黃色與洋紅色之間
		else if (g == max) h = 2 + rc - bc;			// 青色與黃色之間
		else /* if (b == max) */ h = 4 + gc - rc;	// 洋紅色與青色之間
		
		h *= 60.0f;									// 轉成度數
		if (h < 0.0f) h += 360.0f;					// 不能為負數
	}
	
	if (pH) *pH = h;
	if (pS) *pS = s;
	if (pV) *pV = v;
}

void hsbtorgb(CGFloat h, CGFloat s, CGFloat v, CGFloat *pR, CGFloat *pG, CGFloat *pB)
{
	CGFloat r = 0.0f;
	CGFloat g = 0.0f;
	CGFloat b = 0.0f;
	
	// 從Foley與Van Dam那抄來的
	
	if (s == 0.0f) {
		// 無顏色：沒有色調
		r = g = b = v;
	} else {
		// 有顏色：有色調
		if (h == 360.0f) h = 0.0f;
		h /= 60.0f;										// 現在，h在[0, 6)之間
		
		int i = floorf(h);								// 最大整數 <= h
		CGFloat f = h - i;								// h的小數點的部份
		CGFloat p = v * (1 - s);
		CGFloat q = v * (1 - (s * f));
		CGFloat t = v * (1 - (s * (1 - f)));
		
		switch (i) {
			case 0:	r = v; g = t; b = p;	break;
			case 1:	r = q; g = v; b = p;	break;
			case 2:	r = p; g = v; b = t;	break;
			case 3:	r = p; g = q; b = v;	break;
			case 4:	r = t; g = p; b = v;	break;
			case 5:	r = v; g = p; b = q;	break;
		}
	}
	
	if (pR) *pR = r;
	if (pG) *pG = g;
	if (pB) *pB = b;
}
