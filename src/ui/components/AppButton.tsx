import React from 'react';
import {
  Pressable,
  Text,
  View,
  type PressableProps,
  type StyleProp,
  type TextStyle,
  type ViewStyle,
} from 'react-native';
import tw from '~/ui/tailwind-extend';

type AppButtonVariant = 'solid' | 'ghost';

export interface AppButtonProps extends PressableProps {
  title: string;
  caption?: string;
  variant?: AppButtonVariant;
  style?: StyleProp<ViewStyle>;
  titleStyle?: StyleProp<TextStyle>;
  captionStyle?: StyleProp<TextStyle>;
}

const containerStyles: Record<AppButtonVariant, string> = {
  solid: 'border-white bg-white',
  ghost: 'border-[rgba(143,164,196,0.18)] bg-[rgba(255,255,255,0.06)]',
};

const titleStyles: Record<AppButtonVariant, string> = {
  solid: 'text-ink-900',
  ghost: 'text-white',
};

const captionStyles: Record<AppButtonVariant, string> = {
  solid: 'text-[rgba(11,18,32,0.72)]',
  ghost: 'text-[rgba(238,244,255,0.66)]',
};

export function AppButton({
  title,
  caption,
  variant = 'ghost',
  style,
  titleStyle,
  captionStyle,
  disabled = false,
  ...rest
}: AppButtonProps) {
  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      style={({pressed}) => [
        tw.style(
          'rounded-[22px] border px-5 py-4',
          containerStyles[variant],
          pressed && !disabled ? 'opacity-80' : '',
          disabled ? 'opacity-45' : '',
        ),
        style,
      ]}
      {...rest}
    >
      <View>
        <Text
          style={[
            tw.style('text-base font-semibold tracking-[0.2px]', titleStyles[variant]),
            titleStyle,
          ]}
        >
          {title}
        </Text>
        {caption ? (
          <Text
            style={[
              tw.style('mt-1 text-xs leading-5', captionStyles[variant]),
              captionStyle,
            ]}
          >
            {caption}
          </Text>
        ) : null}
      </View>
    </Pressable>
  );
}

export default AppButton;
