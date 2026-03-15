import React, {useState} from 'react';
import {ScrollView, StatusBar, Text, View} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import AppButton from '~/ui/components/AppButton';
import tw from '~/ui/tailwind-extend';

type FocusId = 'ui' | 'nav' | 'data';

const focusCards: Record<
  FocusId,
  {
    eyebrow: string;
    title: string;
    description: string;
    points: string[];
    accent: string;
  }
> = {
  ui: {
    eyebrow: 'Tailwind Foundation',
    title: 'Use utility classes as the default styling language.',
    description:
      'Static layout, spacing, typography, borders, and surface treatment now belong in Tailwind classes instead of StyleSheet blocks.',
    points: [
      'Prefer tw`...` for stable styles and tw.style(...) for conditional variants.',
      'Keep plain object styles only for values that truly depend on runtime math.',
      'Centralize shared colors and tokens in tailwind.config.js instead of scattering hex values.',
    ],
    accent: 'bg-aqua',
  },
  nav: {
    eyebrow: 'Navigation Ready',
    title: 'The screen shell is prepared for a Tailwind-first app structure.',
    description:
      'Navigation, gesture handling, and safe-area support are already installed, so upcoming screens can follow the same tailwind wrapper and component pattern.',
    points: [
      'Build screens under src/ui/screens with Tailwind as the only default styling tool.',
      'Wrap reusable pieces such as buttons, cards, headers, and tabs as components.',
      'Keep screen files focused on composition, not repeated visual primitives.',
    ],
    accent: 'bg-signal',
  },
  data: {
    eyebrow: 'Data Layer',
    title: 'State, networking, caching, and WebView are in the stack now.',
    description:
      'Zustand, Axios, axios-cache-interceptor, and react-native-webview are installed, so feature work can move directly into actual screens and flows.',
    points: [
      'Use Tailwind on loading, empty, error, and data-ready states so the visual system stays consistent.',
      'Treat cards, pills, and diagnostics as reusable Tailwind patterns instead of one-off styles.',
      'When a component needs variants, express them as class combinations first.',
    ],
    accent: 'bg-gold',
  },
};

const installedStack = [
  {
    label: 'twrnc',
    tone: 'border-[rgba(105,224,255,0.28)] bg-[rgba(105,224,255,0.12)]',
    textTone: 'text-aqua',
  },
  {
    label: 'React Navigation',
    tone: 'border-[rgba(255,122,89,0.28)] bg-[rgba(255,122,89,0.12)]',
    textTone: 'text-signal',
  },
  {
    label: 'Zustand',
    tone: 'border-[rgba(246,200,107,0.28)] bg-[rgba(246,200,107,0.12)]',
    textTone: 'text-gold',
  },
  {
    label: 'Axios Cache',
    tone: 'border-[rgba(181,156,255,0.28)] bg-[rgba(181,156,255,0.12)]',
    textTone: 'text-lilac',
  },
  {
    label: 'WebView',
    tone: 'border-[rgba(143,164,196,0.28)] bg-[rgba(143,164,196,0.12)]',
    textTone: 'text-mist-200',
  },
];

const focusButtons: Array<{
  id: FocusId;
  title: string;
  caption: string;
}> = [
  {
    id: 'ui',
    title: 'Tailwind UI',
    caption: 'Tokens, utility classes, and reusable primitives.',
  },
  {
    id: 'nav',
    title: 'Navigation Shell',
    caption: 'Safe area, gesture-handler, and screen composition.',
  },
  {
    id: 'data',
    title: 'Data Layer',
    caption: 'Zustand, axios, caching, and embedded web surfaces.',
  },
];

export function HomeScreen() {
  const [activeFocus, setActiveFocus] = useState<FocusId>('ui');
  const activeCard = focusCards[activeFocus];

  return (
    <View style={tw`flex-1 bg-ink-950`}>
      <StatusBar barStyle="light-content" />

      <View pointerEvents="none" style={tw`absolute inset-0`}>
        <View
          style={tw`absolute -top-12 right-[-68px] h-[240px] w-[240px] rounded-full bg-[rgba(255,122,89,0.22)]`}
        />
        <View
          style={tw`absolute top-52 left-[-58px] h-[220px] w-[220px] rounded-full bg-[rgba(105,224,255,0.18)]`}
        />
        <View
          style={tw`absolute bottom-[-96px] right-[-16px] h-[260px] w-[260px] rounded-full bg-[rgba(181,156,255,0.16)]`}
        />
      </View>

      <SafeAreaView style={tw`flex-1`}>
        <ScrollView
          contentInsetAdjustmentBehavior="always"
          contentContainerStyle={tw`px-6 pb-12`}
          showsVerticalScrollIndicator={false}
        >
          <View style={tw`pt-5`}>
            <View style={tw`self-start rounded-full border border-[rgba(255,255,255,0.12)] bg-[rgba(255,255,255,0.06)] px-3 py-1`}>
              <Text style={tw`text-[11px] font-semibold uppercase tracking-[1.8px] text-[#ffd8cf]`}>
                Tailwind-first baseline
              </Text>
            </View>

            <Text style={tw`mt-6 text-[38px] font-semibold leading-[44px] text-white`}>
              NovaShell now styles with{'\n'}
              <Text style={tw`text-aqua`}>utility classes first.</Text>
            </Text>

            <Text style={tw`mt-4 text-base leading-7 text-[rgba(238,244,255,0.72)]`}>
              The sample screen is no longer driven by StyleSheet. This app now has a dedicated Tailwind
              config, a shared tw entry, and a component pattern you can reuse on every new screen.
            </Text>
          </View>

          <View style={tw`mt-8`}>
            {focusButtons.map((button, index) => {
              const isActive = button.id === activeFocus;
              return (
                <AppButton
                  key={button.id}
                  title={button.title}
                  caption={button.caption}
                  onPress={() => setActiveFocus(button.id)}
                  style={tw.style(index > 0 ? 'mt-3' : '', isActive ? 'border-transparent' : '')}
                  variant={isActive ? 'solid' : 'ghost'}
                />
              );
            })}
          </View>

          <View style={tw`mt-8 rounded-[28px] border border-[rgba(143,164,196,0.16)] bg-[rgba(10,16,33,0.84)] p-5`}>
            <View style={tw`flex-row items-center`}>
              <View style={tw.style('h-2.5 w-2.5 rounded-full', activeCard.accent)} />
              <Text style={tw`ml-2 text-[11px] font-semibold uppercase tracking-[1.8px] text-mist-400`}>
                {activeCard.eyebrow}
              </Text>
            </View>

            <Text style={tw`mt-4 text-[25px] font-semibold leading-8 text-white`}>
              {activeCard.title}
            </Text>

            <Text style={tw`mt-3 text-sm leading-6 text-[rgba(238,244,255,0.74)]`}>
              {activeCard.description}
            </Text>

            <View style={tw`mt-5`}>
              {activeCard.points.map((point, index) => (
                <View key={point} style={tw.style('flex-row items-start', index > 0 ? 'mt-3' : '')}>
                  <View style={tw`mt-1 h-2 w-2 rounded-full bg-mist-300`} />
                  <Text style={tw`ml-3 flex-1 text-sm leading-6 text-mist-200`}>{point}</Text>
                </View>
              ))}
            </View>
          </View>

          <View style={tw`mt-8`}>
            <Text style={tw`text-[11px] font-semibold uppercase tracking-[1.8px] text-mist-400`}>
              Installed stack
            </Text>

            <View style={tw`mt-4 flex-row flex-wrap`}>
              {installedStack.map(item => (
                <View
                  key={item.label}
                  style={tw.style(
                    'mr-2 mb-2 rounded-full border px-3 py-2',
                    item.tone,
                  )}
                >
                  <Text style={tw.style('text-xs font-semibold', item.textTone)}>{item.label}</Text>
                </View>
              ))}
            </View>
          </View>

          <View style={tw`mt-6 rounded-[24px] border border-[rgba(143,164,196,0.16)] bg-[rgba(255,255,255,0.04)] p-5`}>
            <Text style={tw`text-lg font-semibold text-white`}>Working rules going forward</Text>
            <Text style={tw`mt-3 text-sm leading-6 text-[rgba(238,244,255,0.72)]`}>
              Use Tailwind classes for primary layout and visual styling. Reach for plain style objects only
              when a value depends on runtime math, animated interpolation, or a platform API that Tailwind
              cannot express cleanly.
            </Text>
            <Text style={tw`mt-4 text-sm leading-6 text-[rgba(238,244,255,0.72)]`}>
              That keeps styles readable, composable, and close to the JSX instead of spreading them across
              file-level StyleSheet blocks.
            </Text>
          </View>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}

export default HomeScreen;
