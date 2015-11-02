# Experiments
* In general, it can be noted that experiments evaluating HTTP/2 either focus
  on performance for desktop browser experiences over WiFi (e.g. HSIS),
  simulate cellular environments (via NS3), or run 3G using a USB-3G-card in a
  laptop.
* This makes sense for having a more precisely controlled environment to
  evaluate whether HTTP/2 _should_ provide PLT improvements for cellular
  devices _in theory_.
* In this paper, we are interested in uncovering the performance differences
  that can be seen between the two major HTTP versions _in practice_.

## k-TCP
### Overview
* H2 makes a big point to use a _single_ (_persistent_) TCP connection [WHY?].
* This has been shown to be problematic over cellular connections [WHERE?].
* We shall vary the number of TCP connections and 
* If there is time, we shall also implement a _persistent_ connection over
  which multiple requests are made, in sequence.

### Methodology
* We don't use TLS
* We don't use HTTP

#### Server
* We used raw Oracle Java SE 8 to implement a k-threaded server.
* This server listens on k adjacent ports, and upon connection, sends a
  configured number of random bytes to the connected client.
* We configure port forwarding on the router to avoid NAT issues to enable our
  server to listen for requests from outside the local area network.

#### Client
* We implemented an iOS 9.0 application in Swift to run on an iPhone 6s
  cellular device.
* Our application opens _k_ simultaneous TCP connections to the Java server
  described above, and receives the configured number of bytes.
* The app records how long this all takes on a _per connection_ basis, and also
  from start-to-finish for all _k_ simultaneous connections.

### The Datas
* The client shall store the nano-time at which
    * the whole thing is initiated
    * each TCP connection 
        * is _established_
        * data starts being received
        * data is done being received
        * is _closed_
    * The whole thing terminates
* This will be stored in the __following *json* format__
  
    ```json
    {
      "start": nanotime[Long],
      "conns": {
        port1[Int]: {
          "before": nanotime,
          "connEstablished": nanotime,
          "firstByteRcvd": nanotime,
          "dataDone": nanotime,
          "closed": nanotime
        },
        port2[Int]: ...,
        ...
      },
      "end": nanotime
    }
    ```

## H1 vs H2
### Overview
* Until recently, testing the performance impact of H2 has been largely
  speculative because there were very few existing reliable implementations of
  the protocol for both server side and for client side.
* This is starting to change, as evidenced here [link to implementations wiki].

#### Server
* We wanted to make sure the same framework would be used for both our H1 and H2 experimental trials.
* For this reason, the open-source Jetty framework (in Java) was most suitable.

#### Client
* Apple's iOS 9 contains a (private) implementation of HTTP/2 which is used
  automatically [__by which upgrade mechanism?__] when the server says it's
  available.
