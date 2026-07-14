# Multi-Control-Plane Architecture

Single Control Plane

```
API Server
Scheduler
Controller Manager
etcd
```

↓

```
Failure

↓

Cluster unavailable
```

High Availability

```
Control Plane 1

API Server
Scheduler
Controller
etcd

        |

Load Balancer

        |

Control Plane 2

API Server
Scheduler
Controller
etcd

        |

Workers
```

Benefits

- No single point of failure
- Rolling maintenance
- Higher availability
- Production architecture
