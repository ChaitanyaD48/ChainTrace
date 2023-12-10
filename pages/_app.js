import "../styles/globals.css";

import { TrackingProvider } from "../Context/TrackingContext";
import { NavBar, Footer, Services} from "../Components";

export default function App({ Component, pageProps }) {
  return (
    <>
    <TrackingProvider>
    <NavBar/>
    {/* <Services /> */}
    <Component {...pageProps} />
    </TrackingProvider>
    <Footer />
    </>
  );
}
