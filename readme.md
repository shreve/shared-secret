Shared Secrets
==============

Create shares of a secret code which need to be reunited to reveal the secret.

## Usage

```bash
# Create 7 shares of the password which require at least 3 to recreate
$ secret create 7 3 "Howdy, partner!"
1-1026197645290506249894399987748734333070887531064
2-1519067637302214266153992634504989515382450532105
3-2073980667262818795364669700682561085860817681862
4-2690936735172319837526431186281449044505988980335
5-3369935841030717392639277091301653391317964427524
6-4110977984838011460703207415743174126296744023429
7-4914063166594202041718222159606011249442327768050

# Combine the shares to restore the secret
$ secret create 7 3 "Howdy, partner!" | xargs secret decode
Howdy, partner!

# The secret cannot be restored with too few shares
$ secret create 7 3 "Howdy, partner!" | tail -2 | xargs secret decode
Unable to decode input
```

This encoding is based on a 2048-bit prime and has a message space around 192 bytes.

## Under the Hood

This project was inspired by a homework assignment in EECS 376 (Foundations of Computer Science) at the University of Michigan.

Given the parameters of a secret, a number of shares, and a number of required shares, it's possible to generate a polynomial which has the secret as a y-intercept. To generate password shares, simply pull (x, y) coordinates from the equation. You can then reconstruct the polynomial and recover the secret using those coordinates and [Lagrange interpolation](https://en.wikipedia.org/wiki/Lagrange_polynomial).

This library accepts strings as secrets and encodes them as numbers which can be used in the equation. On decode, it reconstructs the polynomial, extracts the secret, and converts it back to a string.

## Problems

1. Occasionally a partial recovery is possible with fewer than required shares.

   ```bash
   $ secret create 7 3 "Howdy, partner!" | tail -2 | xargs secret decode
   X_wdy, partner!
   ```

   This does require at least 2 shares, and only occurs rarely, but is still a vulnerability.
2. This code relies on extensions of Ruby standard library classes Integer and Array. A good implementation wouldn't do that.
