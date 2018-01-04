/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.facebook.yoga;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class YogaNodeTest {

  @Test
  public void testInit() {
    final int refCount = YogaNode.jni_YGNodeGetInstanceCount();
    final YogaNode node = new YogaNode();
    assertEquals(refCount + 1, YogaNode.jni_YGNodeGetInstanceCount());
  }

  @Test
  public void testBaseline() {
    final YogaNode root = new YogaNode();
    root.setFlexDirection(YogaFlexDirection.ROW);
    root.setAlignItems(YogaAlign.BASELINE);
    root.setWidth(100);
    root.setHeight(100);

    final YogaNode child1 = new YogaNode();
    child1.setWidth(40);
    child1.setHeight(40);
    root.addChildAt(child1, 0);

    final YogaNode child2 = new YogaNode();
    child2.setWidth(40);
    child2.setHeight(40);
    child2.setBaselineFunction(new YogaBaselineFunction() {
        public float baseline(YogaNode node, float width, float height) {
          return 0;
        }
    });
    root.addChildAt(child2, 1);

    root.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);

    assertEquals(0, (int) child1.getLayoutY());
    assertEquals(40, (int) child2.getLayoutY());
  }

  @Test
  public void testMeasure() {
    final YogaNode node = new YogaNode();
    node.setMeasureFunction(new YogaMeasureFunction() {
        public long measure(
            YogaNode node,
            float width,
            YogaMeasureMode widthMode,
            float height,
            YogaMeasureMode heightMode) {
          return YogaMeasureOutput.make(100, 100);
        }
    });
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
    assertEquals(100, (int) node.getLayoutWidth());
    assertEquals(100, (int) node.getLayoutHeight());
  }

  @Test
  public void testMeasureFloat() {
    final YogaNode node = new YogaNode();
    node.setMeasureFunction(new YogaMeasureFunction() {
        public long measure(
            YogaNode node,
            float width,
            YogaMeasureMode widthMode,
            float height,
            YogaMeasureMode heightMode) {
          return YogaMeasureOutput.make(100.5f, 100.5f);
        }
    });
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
    assertEquals(101f, node.getLayoutWidth(), 0.01f);
    assertEquals(101f, node.getLayoutHeight(), 0.01f);
  }

  @Test
  public void testMeasureFloatMin() {
    final YogaNode node = new YogaNode();
    node.setMeasureFunction(new YogaMeasureFunction() {
        public long measure(
            YogaNode node,
            float width,
            YogaMeasureMode widthMode,
            float height,
            YogaMeasureMode heightMode) {
          return YogaMeasureOutput.make(Float.MIN_VALUE, Float.MIN_VALUE);
        }
    });
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
    assertEquals(Float.MIN_VALUE, node.getLayoutWidth(), 0.01f);
    assertEquals(Float.MIN_VALUE, node.getLayoutHeight(), 0.01f);
  }

  @Test
  public void testMeasureFloatMax() {
    final YogaNode node = new YogaNode();
    node.setMeasureFunction(new YogaMeasureFunction() {
        public long measure(
            YogaNode node,
            float width,
            YogaMeasureMode widthMode,
            float height,
            YogaMeasureMode heightMode) {
          return YogaMeasureOutput.make(Float.MAX_VALUE, Float.MAX_VALUE);
        }
    });
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
    assertEquals(Float.MAX_VALUE, node.getLayoutWidth(), 0.01f);
    assertEquals(Float.MAX_VALUE, node.getLayoutHeight(), 0.01f);
  }

  @Test
  public void testCopyStyle() {
    final YogaNode node0 = new YogaNode();
    assertTrue(YogaConstants.isUndefined(node0.getMaxHeight()));

    final YogaNode node1 = new YogaNode();
    node1.setMaxHeight(100);

    node0.copyStyle(node1);
    assertEquals(100, (int) node0.getMaxHeight().value);
  }

  @Test
  public void testLayoutMargin() {
    final YogaNode node = new YogaNode();
    node.setWidth(100);
    node.setHeight(100);
    node.setMargin(YogaEdge.START, 1);
    node.setMargin(YogaEdge.END, 2);
    node.setMargin(YogaEdge.TOP, 3);
    node.setMargin(YogaEdge.BOTTOM, 4);
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);

    assertEquals(1, (int) node.getLayoutMargin(YogaEdge.LEFT));
    assertEquals(2, (int) node.getLayoutMargin(YogaEdge.RIGHT));
    assertEquals(3, (int) node.getLayoutMargin(YogaEdge.TOP));
    assertEquals(4, (int) node.getLayoutMargin(YogaEdge.BOTTOM));
  }

  @Test
  public void testLayoutPadding() {
    final YogaNode node = new YogaNode();
    node.setWidth(100);
    node.setHeight(100);
    node.setPadding(YogaEdge.START, 1);
    node.setPadding(YogaEdge.END, 2);
    node.setPadding(YogaEdge.TOP, 3);
    node.setPadding(YogaEdge.BOTTOM, 4);
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);

    assertEquals(1, (int) node.getLayoutPadding(YogaEdge.LEFT));
    assertEquals(2, (int) node.getLayoutPadding(YogaEdge.RIGHT));
    assertEquals(3, (int) node.getLayoutPadding(YogaEdge.TOP));
    assertEquals(4, (int) node.getLayoutPadding(YogaEdge.BOTTOM));
  }

  @Test
  public void testLayoutBorder() {
    final YogaNode node = new YogaNode();
    node.setWidth(100);
    node.setHeight(100);
    node.setBorder(YogaEdge.START, 1);
    node.setBorder(YogaEdge.END, 2);
    node.setBorder(YogaEdge.TOP, 3);
    node.setBorder(YogaEdge.BOTTOM, 4);
    node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);

    assertEquals(1, (int) node.getLayoutBorder(YogaEdge.LEFT));
    assertEquals(2, (int) node.getLayoutBorder(YogaEdge.RIGHT));
    assertEquals(3, (int) node.getLayoutBorder(YogaEdge.TOP));
    assertEquals(4, (int) node.getLayoutBorder(YogaEdge.BOTTOM));
  }

  @Test
  public void testUseWebDefaults() {
    final YogaConfig config = new YogaConfig();
    config.setUseWebDefaults(true);
    final YogaNode node = new YogaNode(config);
    assertEquals(YogaFlexDirection.ROW, node.getFlexDirection());
  }

  @Test
  public void testPercentPaddingOnRoot() {
    final YogaNode node = new YogaNode();
    node.setPaddingPercent(YogaEdge.ALL, 10);
    node.calculateLayout(50, 50);

    assertEquals(5, (int) node.getLayoutPadding(YogaEdge.LEFT));
    assertEquals(5, (int) node.getLayoutPadding(YogaEdge.RIGHT));
    assertEquals(5, (int) node.getLayoutPadding(YogaEdge.TOP));
    assertEquals(5, (int) node.getLayoutPadding(YogaEdge.BOTTOM));
  }

  @Test
  public void testDefaultEdgeValues() {
    final YogaNode node = new YogaNode();

    for (YogaEdge edge : YogaEdge.values()) {
      assertEquals(YogaUnit.UNDEFINED, node.getMargin(edge).unit);
      assertEquals(YogaUnit.UNDEFINED, node.getPadding(edge).unit);
      assertEquals(YogaUnit.UNDEFINED, node.getPosition(edge).unit);
      assertTrue(YogaConstants.isUndefined(node.getBorder(edge)));
    }
  }
}
