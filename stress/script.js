import http from 'k6/http';
import { sleep, check } from 'k6';

export default function () {
  http.get('http://hpa.mikroways.localhost/webapp');
  sleep(1);
}
