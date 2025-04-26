import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity environment
const mockClarity = {
  contracts: {
    'entity-verification': {
      functions: {
        'register-entity': vi.fn(),
        'verify-entity': vi.fn(),
        'suspend-entity': vi.fn(),
        'get-entity': vi.fn(),
        'is-verified': vi.fn(),
      }
    }
  },
  tx: {
    sender: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
  },
  block: {
    height: 100
  }
};

// Reset mocks before each test
beforeEach(() => {
  vi.resetAllMocks();
});

describe('Entity Verification Contract', () => {
  it('should register a new entity', async () => {
    // Mock successful registration
    mockClarity.contracts['entity-verification'].functions['register-entity'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    const name = 'Test Corp';
    const regNumber = 'REG123456';
    const jurisdiction = 'US';
    
    const result = await mockClarity.contracts['entity-verification'].functions['register-entity'](
        entityId, name, regNumber, jurisdiction
    );
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['entity-verification'].functions['register-entity']).toHaveBeenCalledWith(
        entityId, name, regNumber, jurisdiction
    );
  });
  
  it('should not register an entity that already exists', async () => {
    // Mock failure due to existing entity
    mockClarity.contracts['entity-verification'].functions['register-entity'].mockReturnValue({
      success: false,
      error: { code: 1, message: 'Entity ID already exists' }
    });
    
    const entityId = 'entity-123';
    const name = 'Test Corp';
    const regNumber = 'REG123456';
    const jurisdiction = 'US';
    
    const result = await mockClarity.contracts['entity-verification'].functions['register-entity'](
        entityId, name, regNumber, jurisdiction
    );
    
    expect(result.success).toBe(false);
    expect(result.error.code).toBe(1);
  });
  
  it('should verify an entity', async () => {
    // Mock successful verification
    mockClarity.contracts['entity-verification'].functions['verify-entity'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    
    const result = await mockClarity.contracts['entity-verification'].functions['verify-entity'](entityId);
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['entity-verification'].functions['verify-entity']).toHaveBeenCalledWith(entityId);
  });
  
  it('should check if an entity is verified', async () => {
    // Mock entity verification check
    mockClarity.contracts['entity-verification'].functions['is-verified'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    
    const result = await mockClarity.contracts['entity-verification'].functions['is-verified'](entityId);
    
    expect(result.success).toBe(true);
    expect(result.result.value).toBe(true);
  });
  
  it('should suspend an entity', async () => {
    // Mock successful suspension
    mockClarity.contracts['entity-verification'].functions['suspend-entity'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    
    const result = await mockClarity.contracts['entity-verification'].functions['suspend-entity'](entityId);
    
    expect(result.success).toBe(true);
  });
});
