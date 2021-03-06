/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.materials {

	import de.nulldesign.nd2d.materials.texture.SpriteSheetAnimation;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class ASpriteSheetBase {

        protected var frames:Vector.<Rectangle> = new Vector.<Rectangle>();
        protected var offsets:Vector.<Point> = new Vector.<Point>();
        protected var sourceSizes:Vector.<Point> = new Vector.<Point>();
        protected var frameNameToIndex:Dictionary = new Dictionary();
        protected var uvRects:Vector.<Rectangle>;
        protected var spritesPackedWithoutSpace:Boolean;

        protected var ctime:Number = 0.0;
        protected var otime:Number = 0.0;
        protected var interp:Number = 0.0;

        protected var frameIdx:uint = 0;

        protected var activeAnimation:SpriteSheetAnimation;
        protected var animationMap:Dictionary = new Dictionary();

        public var frameUpdated:Boolean = true;

        protected var fps:uint;

        protected var _spriteWidth:Number;
        protected var _spriteHeight:Number;
        protected var _sheetWidth:Number;
        protected var _sheetHeight:Number;

        public function get spriteWidth():Number {
            return _spriteWidth;
        }

        public function get spriteHeight():Number {
            return _spriteHeight;
        }

        protected var _frame:uint = int.MAX_VALUE;

        public function get frame():uint {
            return _frame;
        }

        public function set frame(value:uint):void {
            if(frame != value) {
                _frame = value;
                frameUpdated = true;

                if(frames.length - 1 >= _frame) {
                    _spriteWidth = frames[_frame].width;
                    _spriteHeight = frames[_frame].height;
                }
            }
        }

        public function ASpriteSheetBase() {
        }

        public function update(t:Number):void {

            if(!activeAnimation) return;

            ctime = t;

            // Update the timer part, to get time based animation
            interp += fps * (ctime - otime);
            if(interp >= 1.0) {
                frameIdx++;
                interp = 0;
            }

            if(activeAnimation.loop) {
                frameIdx = frameIdx % activeAnimation.numFrames;
            } else {
                frameIdx = Math.min(frameIdx, activeAnimation.numFrames - 1);
            }

            frame = activeAnimation.frames[frameIdx];

            otime = ctime;
        }

        public function addAnimation(name:String, keyFrames:Array, loop:Boolean, keyIsString:Boolean = false):void {
            animationMap[name] = new SpriteSheetAnimation(keyFrames, loop);
        }

        public function playAnimation(name:String, startIdx:uint = 0, restart:Boolean = false):void {
            if(restart || activeAnimation != animationMap[name]) {
                frameIdx = startIdx;
                activeAnimation = animationMap[name];
            }
        }

        public function clone():ASpriteSheetBase {
            return null;
        }

        public function getOffsetForFrame():Point {
            return offsets[frame];
        }

        public function getUVRectForFrame(textureWidth:Number, textureHeight:Number):Rectangle {

            if(uvRects[frame]) {
                return uvRects[frame];
            }

            var rect:Rectangle = frames[frame].clone();
            var texturePixelOffset:Point = new Point((textureWidth - _sheetWidth) / 2.0, (textureHeight - _sheetHeight) / 2.0);

            rect.x += texturePixelOffset.x;
            rect.y += texturePixelOffset.y;

            if(spritesPackedWithoutSpace) {
                rect.x += 0.5;
                rect.y += 0.5;

                rect.width -= 1.0;
                rect.height -= 1.0;
            }

            rect.x /= textureWidth;
            rect.y /= textureHeight;
            rect.width /= textureWidth;
            rect.height /= textureHeight;

            uvRects[frame] = rect;

            return rect;
        }
    }
}
