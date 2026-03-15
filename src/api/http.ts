import Axios, {type AxiosInstance, type AxiosRequestConfig} from 'axios';
import {setupCache} from 'axios-cache-interceptor';

const DEFAULT_TIMEOUT = 15000;

export interface CreateHttpClientOptions extends AxiosRequestConfig {}

export const createHttpClient = (
  options: CreateHttpClientOptions = {},
): AxiosInstance => {
  return Axios.create({
    timeout: DEFAULT_TIMEOUT,
    ...options,
  });
};

export const createCachedHttpClient = (
  options: CreateHttpClientOptions = {},
): AxiosInstance => {
  return setupCache(createHttpClient(options));
};
