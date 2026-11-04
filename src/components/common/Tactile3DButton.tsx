import React, { useState } from 'react';
import {
  Pressable,
  View,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  Platform,
} from 'react-native';
import { audioManager } from '../../utils/audio';

interface Tactile3DButtonProps {
  onPress: () => void;
  title: string;
  subtitle?: string;
  color: string;
  shadeColor: string;
  textColor?: string;
  icon?: React.ReactNode;
  rightBadge?: string | React.ReactNode;
  style?: ViewStyle;
  contentStyle?: ViewStyle;
  textStyle?: TextStyle;
  disabled?: boolean;
  extrusionDepth?: number;
  height?: number;
}

export const Tactile3DButton: React.FC<Tactile3DButtonProps> = ({
  onPress,
  title,
  subtitle,
  color,
  shadeColor,
  textColor = '#FFFFFF',
  icon,
  rightBadge,
  style,
  contentStyle,
  textStyle,
  disabled = false,
  extrusionDepth = 5,
  height = 54,
}) => {
  const [isPressed, setIsPressed] = useState(false);

  const handlePress = () => {
    if (disabled) return;
    audioManager.playClick();
    onPress();
  };

  const translateY = isPressed ? extrusionDepth - 1 : 0;
  const currentExtrusion = isPressed ? 1 : extrusionDepth;

  return (
    <Pressable
      onPressIn={() => !disabled && setIsPressed(true)}
      onPressOut={() => setIsPressed(false)}
      onPress={handlePress}
      disabled={disabled}
      style={[
        styles.wrapper,
        {
          height: height + extrusionDepth,
          opacity: disabled ? 0.6 : 1,
        },
        style,
      ]}
    >
      {/* 3D Extrusion Rim (Darker bottom shadow base) */}
      <View
        style={[
          styles.extrusionBase,
          {
            backgroundColor: shadeColor,
            height: height,
            bottom: 0,
            borderRadius: 9999,
          },
        ]}
      />

      {/* Button Top Face */}
      <View
        style={[
          styles.topFace,
          {
            backgroundColor: color,
            height: height,
            transform: [{ translateY }],
            borderRadius: 9999,
            ...Platform.select({
              web: {
                boxShadow: isPressed
                  ? `0 1px 0 ${shadeColor}`
                  : `0 ${currentExtrusion}px 0 ${shadeColor}, 0 6px 12px rgba(0, 0, 0, 0.12)`,
              } as any,
            }),
          },
          contentStyle,
        ]}
      >
        {/* Specular highlight strip on top half */}
        <View style={styles.specularGlint} />

        <View style={styles.contentRow}>
          {icon && <View style={styles.iconContainer}>{icon}</View>}

          <View style={styles.textContainer}>
            <Text style={[styles.mainTitle, { color: textColor }, textStyle]}>
              {title}
            </Text>
            {subtitle ? (
              <Text style={[styles.subTitle, { color: textColor }]}>
                {subtitle}
              </Text>
            ) : null}
          </View>

          {typeof rightBadge === 'string' ? (
            <View style={styles.badgePill}>
              <Text style={styles.badgeText}>{rightBadge}</Text>
            </View>
          ) : (
            rightBadge
          )}
        </View>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: 'relative',
    justifyContent: 'flex-start',
    alignSelf: 'stretch',
    cursor: 'pointer' as any,
    userSelect: 'none' as any,
  },
  extrusionBase: {
    position: 'absolute',
    left: 0,
    right: 0,
  },
  topFace: {
    position: 'relative',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    overflow: 'hidden',
  },
  specularGlint: {
    position: 'absolute',
    top: 0,
    left: 12,
    right: 12,
    height: '42%',
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
    borderTopLeftRadius: 9999,
    borderTopRightRadius: 9999,
  },
  contentRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2,
  },
  iconContainer: {
    marginRight: 8,
  },
  textContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  mainTitle: {
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 0.2,
  },
  subTitle: {
    fontSize: 11,
    fontWeight: '600',
    opacity: 0.9,
    marginTop: -1,
  },
  badgePill: {
    marginLeft: 10,
    backgroundColor: '#FFE66D',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 9999,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '800',
    color: '#6D5E00',
  },
});
