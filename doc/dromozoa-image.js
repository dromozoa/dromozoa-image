// Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-image.
//
// dromozoa-image is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-image is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-image.  If not, see <http://www.gnu.org/licenses/>.

/*jslint for: true, this: true, white: true */
/*global global */
"use strict";
(function (root) {
  var $ = root.jQuery;
  $(function () {
    $.getJSON("dromozoa-image.json", function (data) {
      var header = data[1],
          source = data[2],
          w = header.width,
          h = header.height,
          max = header.max,
          channels = header.channels,
          canvas = $("<canvas>").attr({
            width: w,
            height: h
          }).appendTo("body"),
          context = canvas.get(0).getContext("2d"),
          image_data = context.getImageData(0, 0, w, h),
          target = image_data.data,
          i, s, t, v;

      v = 256 / (max + 1)
      if (channels == 1) {
        for (i = 0; i < w * h; i += 1) {
          s = i;
          t = i * 4;
          target[t] = source[s] * v;
          target[t + 1] = source[s] * v;
          target[t + 2] = source[s] * v;
          target[t + 3] = 255;
        }
      } else if (channels == 2) {
        for (i = 0; i < w * h; i += 1) {
          s = i * 2;
          t = i * 4;
          target[t] = source[s] * v;
          target[t + 1] = source[s] * v;
          target[t + 2] = source[s] * v;
          target[t + 3] = source[s + 1];
        }
      } else if (channels == 3) {
        for (i = 0; i < w * h; i += 1) {
          s = i * 3;
          t = i * 4;
          target[t] = source[s] * v;
          target[t + 1] = source[s + 1] * v;
          target[t + 2] = source[s + 2] * v;
          target[t + 3] = 255;
        }
      } else if (channels == 4) {
        for (i = 0; i < w * h; i += 1) {
          s = i * 4;
          t = i * 4;
          target[t] = source[s];
          target[t + 1] = source[s + 1];
          target[t + 2] = source[s + 2];
          target[t + 3] = source[s + 3];
        }
      }

      context.putImageData(image_data, 0, 0);
      // console.log(canvas.get(0).toDataURL("image/png"));
    });
  });
}(this.self || global));
